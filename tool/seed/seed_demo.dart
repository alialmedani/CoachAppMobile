// CoachApp — standalone demo-data seeder (NOT part of the app build/runtime).
//
// Run from the repo root against a running CoachApp backend:
//
//   dart run tool/seed/seed_demo.dart
//
// It uses ONLY the existing REST API (the same endpoints the mobile app calls) —
// no backend/schema/migration/DbMigrator changes. It authenticates as the demo
// tenant's admin (the "coach"), seeds the coach libraries + one active workout &
// nutrition plan per trainee + coach-side progress/notes, then authenticates as
// each trainee to seed their historical workout/nutrition logs.
//
// It is SAFE TO RE-RUN: every entity is checked for existence first (by name for
// libraries/plans, by userName for trainees, by date for logs/progress/notes)
// and skipped/reused instead of duplicated. Today is left unlogged on purpose so
// the live "Log workout / Log nutrition" walkthrough can be performed by hand.
//
// Config (all overridable via environment variables; defaults match the project
// demo tenant): API_BASE_URL, COACHAPP_TENANT, COACHAPP_COACH_USER,
// COACHAPP_COACH_PASS, COACHAPP_TRAINEE_PASS.
import 'dart:convert';
import 'dart:io';

// --------------------------------------------------------------------------
// Config
// --------------------------------------------------------------------------
String _env(String key, String fallback) {
  final v = Platform.environment[key];
  return (v != null && v.isNotEmpty) ? v : fallback;
}

// Host default is localhost (the emulator uses 10.0.2.2; a host CLI uses localhost).
final String baseUrl = _ensureTrailingSlash(
  _env('API_BASE_URL', 'https://localhost:44370/'),
);
final String tenant = _env('COACHAPP_TENANT', 'demo');
final String coachUser = _env('COACHAPP_COACH_USER', 'admin');
final String coachPass = _env('COACHAPP_COACH_PASS', '1q2w3E*');
final String traineePass = _env('COACHAPP_TRAINEE_PASS', 'Trainee1*');

// OpenIddict public client (mirrors login_params.dart in the app).
const String clientId = 'CoachApp_App';
const String scope = 'CoachApp offline_access profile email phone roles';

String _ensureTrailingSlash(String s) => s.endsWith('/') ? s : '$s/';

final HttpClient _http = _makeHttpClient();

HttpClient _makeHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true; // dev self-signed
  client.connectionTimeout = const Duration(seconds: 20);
  return client;
}

// --------------------------------------------------------------------------
// Counters (for the final report)
// --------------------------------------------------------------------------
final _stats = <String, int>{
  'trainees_created': 0,
  'trainees_reused': 0,
  'exercises_created': 0,
  'exercises_reused': 0,
  'foods_created': 0,
  'foods_reused': 0,
  'workout_plans_created': 0,
  'workout_plans_reused': 0,
  'nutrition_plans_created': 0,
  'nutrition_plans_reused': 0,
  'progress_created': 0,
  'progress_skipped': 0,
  'workout_logs_created': 0,
  'workout_logs_skipped': 0,
  'nutrition_logs_created': 0,
  'nutrition_logs_skipped': 0,
  'notes_created': 0,
  'notes_skipped': 0,
};
void _bump(String k, [int n = 1]) => _stats[k] = (_stats[k] ?? 0) + n;

// --------------------------------------------------------------------------
// HTTP helpers
// --------------------------------------------------------------------------
Future<dynamic> _request(
  String method,
  String path, {
  Object? jsonBody,
  Map<String, String>? formBody,
  String? token,
  Map<String, String>? query,
}) async {
  var uri = Uri.parse('$baseUrl$path');
  if (query != null && query.isNotEmpty) {
    uri = uri.replace(queryParameters: {...uri.queryParameters, ...query});
  }
  final req = await _http.openUrl(method, uri);
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  if (tenant.isNotEmpty) req.headers.set('__tenant', tenant);
  if (token != null) {
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
  if (formBody != null) {
    req.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
    );
    final encoded = formBody.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');
    req.add(utf8.encode(encoded));
  } else if (jsonBody != null) {
    req.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
    req.add(utf8.encode(jsonEncode(jsonBody)));
  }
  final resp = await req.close();
  final text = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    return text.trim().isEmpty ? null : jsonDecode(text);
  }
  throw _ApiException(method, path, resp.statusCode, text);
}

class _ApiException implements Exception {
  final String method, path, body;
  final int status;
  _ApiException(this.method, this.path, this.status, this.body);
  @override
  String toString() => '$method $path -> HTTP $status: ${_truncate(body)}';
  static String _truncate(String s) => s.length > 300 ? s.substring(0, 300) : s;
}

Future<String> _login(String user, String pass) async {
  final data = await _request(
    'POST',
    'connect/token',
    formBody: {
      'grant_type': 'password',
      'client_id': clientId,
      'scope': scope,
      'username': user,
      'password': pass,
    },
  ) as Map<String, dynamic>;
  return data['access_token'] as String;
}

/// Returns the `items` of an ABP `PagedResultDto` (or a raw list if the endpoint
/// returns a top-level array).
Future<List<dynamic>> _getList(
  String path,
  String token, {
  Map<String, String>? query,
}) async {
  final data = await _request('GET', path, token: token, query: {
    'MaxResultCount': '1000',
    ...?query,
  });
  if (data is List) return data;
  if (data is Map && data['items'] is List) return data['items'] as List;
  return const [];
}

String _dayKey(dynamic isoDate) {
  if (isoDate == null) return '';
  final s = isoDate.toString();
  return s.length >= 10 ? s.substring(0, 10) : s; // yyyy-MM-dd
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}T00:00:00';

/// .NET DayOfWeek: Sunday=0..Saturday=6. Dart weekday: Monday=1..Sunday=7.
int _netDow(DateTime d) => d.weekday % 7;

void _log(String msg) => stdout.writeln(msg);

// --------------------------------------------------------------------------
// Catalog data
// --------------------------------------------------------------------------
// Exercise: name, targetMuscle(int), equipment(int).
// MuscleGroup: other0 chest1 back2 shoulders3 arms4 legs5 core6 fullBody7 cardio8
// Equipment:   none0 bodyweight1 barbell2 dumbbell3 machine4 cable5 kettlebell6 band7 other8
const List<List<Object>> _exercises = [
  ['Barbell Bench Press', 1, 2],
  ['Incline Dumbbell Press', 1, 3],
  ['Cable Fly', 1, 5],
  ['Deadlift', 2, 2],
  ['Pull-up', 2, 1],
  ['Bent-over Row', 2, 2],
  ['Lat Pulldown', 2, 4],
  ['Back Squat', 5, 2],
  ['Leg Press', 5, 4],
  ['Romanian Deadlift', 5, 2],
  ['Walking Lunge', 5, 3],
  ['Overhead Press', 3, 2],
  ['Lateral Raise', 3, 3],
  ['Barbell Curl', 4, 2],
  ['Triceps Pushdown', 4, 5],
  ['Plank', 6, 1],
  ['Hanging Leg Raise', 6, 1],
  ['Treadmill Run', 8, 4],
];

// Food: name, servingSize, servingUnit, calories, proteinG, carbsG, fatG.
const List<List<Object>> _foods = [
  ['Chicken Breast', 100, 'g', 165, 31, 0, 3.6],
  ['Salmon', 100, 'g', 208, 20, 0, 13],
  ['Egg', 50, 'g', 78, 6, 0.6, 5],
  ['Greek Yogurt', 100, 'g', 59, 10, 3.6, 0.4],
  ['Whey Protein', 30, 'g', 120, 24, 3, 1.5],
  ['Lean Beef', 100, 'g', 250, 26, 0, 15],
  ['Tuna', 100, 'g', 132, 28, 0, 1],
  ['White Rice', 100, 'g', 130, 2.7, 28, 0.3],
  ['Oats', 40, 'g', 150, 5, 27, 3],
  ['Sweet Potato', 100, 'g', 86, 1.6, 20, 0.1],
  ['Whole-wheat Bread', 40, 'g', 100, 4, 18, 1.5],
  ['Banana', 120, 'g', 105, 1.3, 27, 0.4],
  ['Almonds', 30, 'g', 174, 6, 6, 15],
  ['Peanut Butter', 32, 'g', 190, 8, 6, 16],
  ['Olive Oil', 15, 'ml', 119, 0, 0, 13.5],
  ['Avocado', 100, 'g', 160, 2, 9, 15],
  ['Broccoli', 100, 'g', 34, 2.8, 7, 0.4],
  ['Apple', 150, 'g', 78, 0.4, 21, 0.3],
];

class TraineeSpec {
  final String userName, firstName, lastName;
  final int gender, goal; // enum ints
  final num heightCm, startKg, targetKg;
  final String planName, nutritionName;
  final Map<String, num> targets; // calories/protein/carbs/fat
  final double loadFactor; // scales prescribed weights
  const TraineeSpec(
    this.userName,
    this.firstName,
    this.lastName,
    this.gender,
    this.goal,
    this.heightCm,
    this.startKg,
    this.targetKg,
    this.planName,
    this.nutritionName,
    this.targets,
    this.loadFactor,
  );
  String get email => '$userName@demo.coachapp';
}

const List<TraineeSpec> _trainees = [
  TraineeSpec('ahmed', 'Ahmed', 'Ali', 1, 2, 180, 81.5, 85, 'Push / Pull / Legs',
      'Lean Bulk 2600', {'c': 2600, 'p': 180, 'cb': 280, 'f': 80}, 1.0),
  TraineeSpec('sara', 'Sara', 'Hassan', 2, 1, 165, 72, 62, 'Full-Body Fat-Loss',
      'Cutting 1700', {'c': 1700, 'p': 140, 'cb': 150, 'f': 50}, 0.55),
  TraineeSpec('omar', 'Omar', 'Khaled', 1, 5, 178, 88, 92, '5x5 Strength',
      'Strength Surplus 2900', {'c': 2900, 'p': 190, 'cb': 320, 'f': 90}, 1.35),
  TraineeSpec('layla', 'Layla', 'Mahmoud', 2, 4, 170, 68, 63, 'Conditioning & Tone',
      'Balanced 1900', {'c': 1900, 'p': 130, 'cb': 190, 'f': 60}, 0.6),
  TraineeSpec('youssef', 'Youssef', 'Nabil', 1, 3, 175, 76, 76, 'Upper / Lower Maintenance',
      'Maintenance 2300', {'c': 2300, 'p': 150, 'cb': 240, 'f': 70}, 0.85),
];

// A 3-day workout template. Each entry: exercise name, sets, reps, baseWeightKg, rest.
// baseWeightKg is scaled per trainee by loadFactor (0 => bodyweight, left null).
final Map<String, List<List<Object?>>> _workoutTemplate = {
  'Push': [
    ['Barbell Bench Press', 4, '6-8', 60, 120],
    ['Incline Dumbbell Press', 3, '8-10', 22, 90],
    ['Overhead Press', 3, '8-10', 35, 90],
    ['Triceps Pushdown', 3, '10-12', 25, 60],
    ['Lateral Raise', 3, '12-15', 8, 45],
  ],
  'Pull': [
    ['Deadlift', 4, '5', 100, 150],
    ['Pull-up', 3, '6-10', null, 90],
    ['Bent-over Row', 3, '8-10', 50, 90],
    ['Barbell Curl', 3, '10-12', 25, 60],
    ['Hanging Leg Raise', 3, '10-15', null, 60],
  ],
  'Legs': [
    ['Back Squat', 4, '6-8', 80, 150],
    ['Leg Press', 3, '10-12', 140, 90],
    ['Romanian Deadlift', 3, '8-10', 60, 90],
    ['Walking Lunge', 3, '12', 16, 60],
    ['Plank', 3, '45s', null, 45],
  ],
};

// A 4-meal nutrition template. Each item: food name, quantity (servings).
final Map<String, List<List<Object>>> _nutritionTemplate = {
  'Breakfast': [
    ['Oats', 1.5],
    ['Egg', 2],
    ['Banana', 1],
  ],
  'Lunch': [
    ['Chicken Breast', 2],
    ['White Rice', 1.5],
    ['Broccoli', 1],
    ['Olive Oil', 1],
  ],
  'Dinner': [
    ['Salmon', 1.5],
    ['Sweet Potato', 2],
    ['Broccoli', 1],
  ],
  'Snack': [
    ['Greek Yogurt', 1.5],
    ['Almonds', 1],
    ['Apple', 1],
  ],
};

// --------------------------------------------------------------------------
// Seeding steps
// --------------------------------------------------------------------------
Future<Map<String, String>> _seedLibrary(
  String coachToken,
  String path,
  List<List<Object>> rows,
  Map<String, dynamic> Function(List<Object> row) toBody,
  String createdStat,
  String reusedStat,
) async {
  final existing = await _getList(path, coachToken);
  final byName = <String, String>{
    for (final e in existing)
      (e['name'] as String): (e['id']).toString(),
  };
  final result = <String, String>{};
  for (final row in rows) {
    final name = row[0] as String;
    if (byName.containsKey(name)) {
      result[name] = byName[name]!;
      _bump(reusedStat);
      continue;
    }
    final created = await _request('POST', path, jsonBody: toBody(row), token: coachToken)
        as Map<String, dynamic>;
    result[name] = created['id'].toString();
    _bump(createdStat);
  }
  return result;
}

Future<Map<String, dynamic>> _ensureTrainee(
  String coachToken,
  TraineeSpec t,
  Map<String, String> existingByUserName,
) async {
  if (existingByUserName.containsKey(t.userName)) {
    _bump('trainees_reused');
    // Fetch full dto for the id.
    final id = existingByUserName[t.userName]!;
    return {'id': id, 'userName': t.userName};
  }
  final created = await _request(
    'POST',
    'api/app/trainee',
    token: coachToken,
    jsonBody: {
      'userName': t.userName,
      'password': traineePass,
      'firstName': t.firstName,
      'lastName': t.lastName,
      'email': t.email,
      'gender': t.gender,
      'goal': t.goal,
      'heightCm': t.heightCm,
      'startWeightKg': t.startKg,
      'targetWeightKg': t.targetKg,
      'isActive': true,
    },
  ) as Map<String, dynamic>;
  _bump('trainees_created');
  return created;
}

Future<Map<String, dynamic>> _ensureWorkoutPlan(
  String coachToken,
  String traineeId,
  TraineeSpec t,
  Map<String, String> exerciseIds,
) async {
  final plans = await _getList(
    'api/app/workout-plan',
    coachToken,
    query: {'TraineeId': traineeId},
  );
  final match = plans.cast<Map<String, dynamic>>().where((p) => p['name'] == t.planName);
  if (match.isNotEmpty) {
    _bump('workout_plans_reused');
    // Re-fetch full tree so we have day ids.
    final full = await _request('GET', 'api/app/workout-plan/${match.first['id']}',
        token: coachToken) as Map<String, dynamic>;
    await _ensureActiveWorkout(coachToken, full);
    return full;
  }

  final today = DateTime.now();
  final dayNames = _workoutTemplate.keys.toList();
  final days = <Map<String, dynamic>>[];
  for (var i = 0; i < dayNames.length; i++) {
    final dayName = dayNames[i];
    final scheduled = _netDow(today.add(Duration(days: i * 2))); // A=today, then +2,+4
    final exercises = <Map<String, dynamic>>[];
    final rows = _workoutTemplate[dayName]!;
    for (var j = 0; j < rows.length; j++) {
      final r = rows[j];
      final exName = r[0] as String;
      final exId = exerciseIds[exName];
      if (exId == null) continue;
      final baseWeight = r[3] as num?;
      exercises.add({
        'exerciseId': exId,
        'order': j,
        'sets': r[1],
        'reps': r[2],
        if (baseWeight != null)
          'weightKg': double.parse((baseWeight * t.loadFactor).toStringAsFixed(1)),
        'restSeconds': r[4],
      });
    }
    days.add({
      'name': dayName,
      'order': i,
      'scheduledDay': scheduled,
      'exercises': exercises,
    });
  }

  final created = await _request(
    'POST',
    'api/app/workout-plan',
    token: coachToken,
    jsonBody: {
      'traineeId': traineeId,
      'name': t.planName,
      'description': '${t.firstName}\'s primary training block.',
      'isActive': true,
      'days': days,
    },
  ) as Map<String, dynamic>;
  _bump('workout_plans_created');
  await _ensureActiveWorkout(coachToken, created);
  return created;
}

Future<void> _ensureActiveWorkout(String coachToken, Map<String, dynamic> plan) async {
  if (plan['isActive'] == true) return;
  await _request('POST', 'api/app/workout-plan/${plan['id']}/set-active', token: coachToken);
}

Future<Map<String, dynamic>> _ensureNutritionPlan(
  String coachToken,
  String traineeId,
  TraineeSpec t,
  Map<String, String> foodIds,
) async {
  final plans = await _getList(
    'api/app/nutrition-plan',
    coachToken,
    query: {'TraineeId': traineeId},
  );
  final match =
      plans.cast<Map<String, dynamic>>().where((p) => p['name'] == t.nutritionName);
  if (match.isNotEmpty) {
    _bump('nutrition_plans_reused');
    final full = await _request('GET', 'api/app/nutrition-plan/${match.first['id']}',
        token: coachToken) as Map<String, dynamic>;
    await _ensureActiveNutrition(coachToken, full);
    return full;
  }

  final mealNames = _nutritionTemplate.keys.toList();
  final meals = <Map<String, dynamic>>[];
  for (var i = 0; i < mealNames.length; i++) {
    final mealName = mealNames[i];
    final items = <Map<String, dynamic>>[];
    final rows = _nutritionTemplate[mealName]!;
    for (var j = 0; j < rows.length; j++) {
      final foodName = rows[j][0] as String;
      final qty = rows[j][1] as num;
      final foodId = foodIds[foodName];
      if (foodId == null) continue;
      items.add({'foodId': foodId, 'order': j, 'quantity': qty});
    }
    meals.add({'name': mealName, 'order': i, 'items': items});
  }

  final created = await _request(
    'POST',
    'api/app/nutrition-plan',
    token: coachToken,
    jsonBody: {
      'traineeId': traineeId,
      'name': t.nutritionName,
      'description': '${t.firstName}\'s daily nutrition plan.',
      'isActive': true,
      'targetCalories': t.targets['c'],
      'targetProteinG': t.targets['p'],
      'targetCarbsG': t.targets['cb'],
      'targetFatG': t.targets['f'],
      'meals': meals,
    },
  ) as Map<String, dynamic>;
  _bump('nutrition_plans_created');
  await _ensureActiveNutrition(coachToken, created);
  return created;
}

Future<void> _ensureActiveNutrition(String coachToken, Map<String, dynamic> plan) async {
  if (plan['isActive'] == true) return;
  await _request('POST', 'api/app/nutrition-plan/${plan['id']}/set-active', token: coachToken);
}

Future<void> _seedProgress(String coachToken, String traineeId, TraineeSpec t) async {
  final existing = await _getList('api/app/progress-entry', coachToken,
      query: {'TraineeId': traineeId});
  final existingDates = existing.map((e) => _dayKey(e['date'])).toSet();

  final today = DateTime.now();
  // 5 weekly points: 5,4,3,2,1 weeks ago (today left for the live walkthrough).
  for (var w = 5; w >= 1; w--) {
    final date = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: w * 7));
    final key = _dayKey(_iso(date));
    if (existingDates.contains(key)) {
      _bump('progress_skipped');
      continue;
    }
    // Interpolate weight from start toward target across 5 weeks.
    final frac = (5 - w) / 5.0;
    final weight = t.startKg + (t.targetKg - t.startKg) * frac;
    final bodyFat = (t.gender == 2 ? 28.0 : 20.0) -
        frac * (t.goal == 1 ? 4.0 : 2.0); // drops more when cutting
    await _request('POST', 'api/app/progress-entry', token: coachToken, jsonBody: {
      'traineeId': traineeId,
      'date': _iso(date),
      'weightKg': double.parse(weight.toStringAsFixed(1)),
      'bodyFatPercent': double.parse(bodyFat.toStringAsFixed(1)),
      'waistCm': double.parse(((t.gender == 2 ? 78 : 88) - frac * 4).toStringAsFixed(1)),
      'armCm': double.parse(((t.gender == 2 ? 30 : 36) + frac * 1).toStringAsFixed(1)),
      'notes': w == 5 ? 'Baseline measurement.' : null,
    });
    _bump('progress_created');
  }
}

Future<void> _seedNotes(String coachToken, String traineeId, TraineeSpec t) async {
  final existing =
      await _getList('api/app/trainee-note', coachToken, query: {'TraineeId': traineeId});
  final existingDates = existing.map((e) => _dayKey(e['date'])).toSet();

  final today = DateTime.now();
  final notes = <int, String>{
    28: 'Welcome ${t.firstName}! Focus on form and consistency this month.',
    14: 'Great adherence so far — keep protein high and sleep 7-8h.',
    5: 'Progress is on track toward your goal. Push a little harder on the main lifts.',
  };
  for (final entry in notes.entries) {
    final date = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: entry.key));
    if (existingDates.contains(_dayKey(_iso(date)))) {
      _bump('notes_skipped');
      continue;
    }
    await _request('POST', 'api/app/trainee-note', token: coachToken, jsonBody: {
      'traineeId': traineeId,
      'date': _iso(date),
      'text': entry.value,
    });
    _bump('notes_created');
  }
}

Future<void> _seedLogs(TraineeSpec t, Map<String, dynamic> workoutPlan,
    Map<String, dynamic> nutritionPlan) async {
  final token = await _login(t.userName, traineePass);
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Day ids from the workout plan tree (skip if empty).
  final dayIds = (workoutPlan['days'] as List? ?? [])
      .cast<Map<String, dynamic>>()
      .map((d) => d['id'].toString())
      .toList();
  final nutritionPlanId = nutritionPlan['id'].toString();

  // ---- workout logs: 3 sessions/week for the last 4 weeks (~12), past only.
  final existingWo =
      (await _getList('api/app/my-workout-log', token)).map((e) => _dayKey(e['date'])).toSet();
  if (dayIds.isNotEmpty) {
    var dayIdx = 0;
    for (var w = 4; w >= 1; w--) {
      // three sessions on offsets within the week
      for (final off in [1, 3, 5]) {
        final date = today.subtract(Duration(days: w * 7 - off));
        if (!date.isBefore(today)) continue; // never today or future
        if (existingWo.contains(_dayKey(_iso(date)))) {
          _bump('workout_logs_skipped');
          dayIdx++;
          continue;
        }
        try {
          await _request('POST', 'api/app/my-workout-log/from-day', token: token, jsonBody: {
            'workoutDayId': dayIds[dayIdx % dayIds.length],
            'date': _iso(date),
          });
          _bump('workout_logs_created');
        } on _ApiException catch (e) {
          _log('  ! workout log ${_dayKey(_iso(date))} for ${t.userName}: $e');
        }
        dayIdx++;
      }
    }
  }

  // ---- nutrition logs: 5 days/week for the last 4 weeks (~20), past only.
  final existingNu =
      (await _getList('api/app/my-nutrition-log', token)).map((e) => _dayKey(e['date'])).toSet();
  for (var w = 4; w >= 1; w--) {
    for (final off in [0, 1, 2, 4, 6]) {
      final date = today.subtract(Duration(days: w * 7 - off));
      if (!date.isBefore(today)) continue;
      if (existingNu.contains(_dayKey(_iso(date)))) {
        _bump('nutrition_logs_skipped');
        continue;
      }
      try {
        await _request('POST', 'api/app/my-nutrition-log/from-plan', token: token, jsonBody: {
          'nutritionPlanId': nutritionPlanId,
          'date': _iso(date),
        });
        _bump('nutrition_logs_created');
      } on _ApiException catch (e) {
        _log('  ! nutrition log ${_dayKey(_iso(date))} for ${t.userName}: $e');
      }
    }
  }
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------
Future<void> main() async {
  _log('CoachApp demo seeder');
  _log('  base   : $baseUrl');
  _log('  tenant : $tenant');
  _log('  coach  : $coachUser');
  _log('');

  try {
    _log('> Authenticating as coach...');
    final coachToken = await _login(coachUser, coachPass);

    _log('> Seeding exercise library...');
    final exerciseIds = await _seedLibrary(
      coachToken,
      'api/app/exercise',
      _exercises,
      (r) => {
        'name': r[0],
        'targetMuscle': r[1],
        'equipment': r[2],
        'isActive': true,
      },
      'exercises_created',
      'exercises_reused',
    );

    _log('> Seeding food library...');
    final foodIds = await _seedLibrary(
      coachToken,
      'api/app/food',
      _foods,
      (r) => {
        'name': r[0],
        'servingSize': r[1],
        'servingUnit': r[2],
        'calories': r[3],
        'proteinG': r[4],
        'carbsG': r[5],
        'fatG': r[6],
        'isActive': true,
      },
      'foods_created',
      'foods_reused',
    );

    // Existing trainees (idempotency).
    final existingTrainees = await _getList('api/app/trainee', coachToken);
    final traineeByUserName = <String, String>{
      for (final e in existingTrainees)
        (e['userName'] as String): (e['id']).toString(),
    };

    for (final t in _trainees) {
      _log('> Trainee: ${t.userName} (${t.firstName} ${t.lastName})');
      final trainee = await _ensureTrainee(coachToken, t, traineeByUserName);
      final traineeId = trainee['id'].toString();

      final workoutPlan = await _ensureWorkoutPlan(coachToken, traineeId, t, exerciseIds);
      final nutritionPlan = await _ensureNutritionPlan(coachToken, traineeId, t, foodIds);
      await _seedProgress(coachToken, traineeId, t);
      await _seedNotes(coachToken, traineeId, t);

      _log('  - logging in as ${t.userName} to seed historical logs...');
      await _seedLogs(t, workoutPlan, nutritionPlan);
    }

    _log('');
    _log('=== Seed summary ===');
    _stats.forEach((k, v) => _log('  $k: $v'));
    _log('Done.');
  } on _ApiException catch (e) {
    stderr.writeln('SEED FAILED: $e');
    exitCode = 1;
  } catch (e, st) {
    stderr.writeln('SEED FAILED: $e\n$st');
    exitCode = 1;
  } finally {
    _http.close(force: true);
  }
}
