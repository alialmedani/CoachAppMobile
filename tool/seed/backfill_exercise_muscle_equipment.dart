// CoachApp — backfill targetMuscle + equipment on imported exercises.
//
// Matches backend exercises to the free-exercise-db source BY NAME (case-
// insensitive) and sets `targetMuscle` + `equipment` from the source's
// `primaryMuscles[0]` + `equipment`, mapped onto the backend enums. Nothing
// else is touched — instructions/imageUrl/name/etc. are preserved (the PUT
// re-sends the current values unchanged).
//
// Run from the repo root against a RUNNING backend:
//
//   DRY_RUN=1 dart run tool/seed/backfill_exercise_muscle_equipment.dart   # preview
//   dart run tool/seed/backfill_exercise_muscle_equipment.dart             # apply
//
// Uses ONLY the existing REST API (GET + PUT /api/app/exercise) — no backend/
// schema change. Idempotent: an exercise is updated only when the mapped value
// actually differs from what's stored, so re-running is a no-op.
//
// Config (env, defaults match the demo tenant): API_BASE_URL, COACHAPP_TENANT,
// COACHAPP_COACH_USER, COACHAPP_COACH_PASS, EXERCISE_DB_URL, EXERCISE_DB_FILE,
// DRY_RUN.
import 'dart:convert';
import 'dart:io';

// --------------------------------------------------------------------------
// Config
// --------------------------------------------------------------------------
String _env(String key, String fallback) {
  final v = Platform.environment[key];
  return (v != null && v.isNotEmpty) ? v : fallback;
}

String _ensureTrailingSlash(String s) => s.endsWith('/') ? s : '$s/';

final String baseUrl = _ensureTrailingSlash(
  _env('API_BASE_URL', 'https://localhost:44370/'),
);
final String tenant = _env('COACHAPP_TENANT', 'demo');
final String coachUser = _env('COACHAPP_COACH_USER', 'admin');
final String coachPass = _env('COACHAPP_COACH_PASS', '1q2w3E*');
const String clientId = 'CoachApp_App';
const String scope = 'CoachApp offline_access profile email phone roles';
final String datasetUrl = _env(
  'EXERCISE_DB_URL',
  'https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/dist/exercises.json',
);
final String localFile = _env('EXERCISE_DB_FILE', '');
final bool dryRun = _env('DRY_RUN', '') == '1';

// --------------------------------------------------------------------------
// Enum maps  (backend enums, mirrored from exercise_enums.dart / the .NET side)
//   MuscleGroup: other0 chest1 back2 shoulders3 arms4 legs5 core6 fullBody7 cardio8
//   Equipment  : none0 bodyweight1 barbell2 dumbbell3 machine4 cable5 kettlebell6
//                resistanceBand7 other8
// --------------------------------------------------------------------------
const int muscleOther = 0, muscleCardio = 8;
const Map<String, int> _muscleMap = {
  'chest': 1,
  'lats': 2, 'middle back': 2, 'lower back': 2, 'traps': 2,
  'shoulders': 3, 'neck': 3,
  'biceps': 4, 'triceps': 4, 'forearms': 4,
  'quadriceps': 5, 'hamstrings': 5, 'calves': 5, 'glutes': 5,
  'abductors': 5, 'adductors': 5,
  'abdominals': 6,
};

const int equipNone = 0, equipOther = 8;
const Map<String, int> _equipMap = {
  'body only': 1,
  'barbell': 2, 'e-z curl bar': 2,
  'dumbbell': 3,
  'machine': 4,
  'cable': 5,
  'kettlebells': 6,
  'bands': 7,
  'medicine ball': 8, 'exercise ball': 8, 'foam roll': 8, 'other': 8,
};

/// Map a source exercise to a backend MuscleGroup int.
int _mapMuscle(Map<String, dynamic> src) {
  final primary = (src['primaryMuscles'] as List?) ?? const [];
  if (primary.isNotEmpty) {
    final m = _muscleMap[primary.first.toString().trim().toLowerCase()];
    if (m != null) return m;
  }
  // Fallback: source category "cardio" -> cardio pseudo-muscle.
  if ((src['category']?.toString().trim().toLowerCase()) == 'cardio') {
    return muscleCardio;
  }
  return muscleOther;
}

/// Map a source exercise to a backend Equipment int.
int _mapEquipment(Map<String, dynamic> src) {
  final eq = src['equipment']?.toString().trim().toLowerCase();
  if (eq == null || eq.isEmpty) return equipNone;
  return _equipMap[eq] ?? equipOther;
}

// --------------------------------------------------------------------------
// HTTP
// --------------------------------------------------------------------------
final HttpClient _http = _makeHttpClient();
HttpClient _makeHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;
  client.connectionTimeout = const Duration(seconds: 30);
  return client;
}

Future<dynamic> _api(
  String method,
  String path, {
  Object? jsonBody,
  Map<String, String>? formBody,
  String? token,
}) async {
  final uri = Uri.parse('$baseUrl$path');
  final req = await _http.openUrl(method, uri);
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  if (tenant.isNotEmpty) req.headers.set('__tenant', tenant);
  if (token != null) {
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
  if (formBody != null) {
    req.headers.contentType = ContentType('application', 'x-www-form-urlencoded');
    req.add(utf8.encode(formBody.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&')));
  } else if (jsonBody != null) {
    req.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
    req.add(utf8.encode(jsonEncode(jsonBody)));
  }
  final resp = await req.close();
  final text = await resp.transform(utf8.decoder).join();
  if (resp.statusCode >= 200 && resp.statusCode < 300) {
    return text.trim().isEmpty ? null : jsonDecode(text);
  }
  final snippet = text.length > 300 ? '${text.substring(0, 300)}…' : text;
  throw '$method $path -> ${resp.statusCode}: $snippet';
}

Future<String> _login() async {
  final r = await _api('POST', 'connect/token', formBody: {
    'grant_type': 'password',
    'client_id': clientId,
    'scope': scope,
    'username': coachUser,
    'password': coachPass,
  }) as Map;
  final t = r['access_token'] as String?;
  if (t == null || t.isEmpty) throw 'login failed: no access_token';
  return t;
}

Future<String> _fetchRaw(String url) async {
  final req = await _http.getUrl(Uri.parse(url));
  final resp = await req.close();
  if (resp.statusCode != 200) throw 'GET $url -> ${resp.statusCode}';
  return resp.transform(utf8.decoder).join();
}

/// All backend exercises (full DTOs), keyed by lowercased name.
Future<Map<String, Map<String, dynamic>>> _allExercises(String token) async {
  final byName = <String, Map<String, dynamic>>{};
  var skip = 0;
  const take = 200;
  while (true) {
    final r = await _api(
      'GET',
      'api/app/exercise?SkipCount=$skip&MaxResultCount=$take',
      token: token,
    ) as Map;
    final items = (r['items'] as List?) ?? const [];
    for (final e in items) {
      final map = (e as Map).cast<String, dynamic>();
      final n = (map['name'] as String?)?.trim().toLowerCase();
      if (n != null && n.isNotEmpty) byName[n] = map;
    }
    final total = (r['totalCount'] as int?) ?? items.length;
    skip += items.length;
    if (items.isEmpty || skip >= total) break;
  }
  return byName;
}

int _asInt(dynamic v) => v is int ? v : (v is String ? int.tryParse(v) ?? 0 : 0);

const _muscleNames = [
  'other', 'chest', 'back', 'shoulders', 'arms', 'legs', 'core', 'fullBody', 'cardio'
];
const _equipNames = [
  'none', 'bodyweight', 'barbell', 'dumbbell', 'machine', 'cable', 'kettlebell',
  'resistanceBand', 'other'
];
String _mName(int i) => (i >= 0 && i < _muscleNames.length) ? _muscleNames[i] : '$i';
String _eName(int i) => (i >= 0 && i < _equipNames.length) ? _equipNames[i] : '$i';

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------
Future<void> main() async {
  stdout.writeln('CoachApp exercise muscle/equipment backfill');
  stdout.writeln('  base   : $baseUrl');
  stdout.writeln('  tenant : $tenant   coach: $coachUser');
  stdout.writeln('  dryRun : $dryRun');
  stdout.writeln('');

  try {
    // Source dataset.
    String raw;
    if (localFile.isNotEmpty) {
      stdout.writeln('> Reading dataset from file: $localFile');
      raw = await File(localFile).readAsString();
    } else {
      stdout.writeln('> Downloading dataset: $datasetUrl');
      raw = await _fetchRaw(datasetUrl);
    }
    final source = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final srcByName = <String, Map<String, dynamic>>{};
    for (final s in source) {
      final n = (s['name'] as String?)?.trim().toLowerCase();
      if (n != null && n.isNotEmpty) srcByName.putIfAbsent(n, () => s);
    }
    stdout.writeln('  source entries: ${source.length}');

    // Backend exercises.
    stdout.writeln('> Authenticating as coach...');
    final token = await _login();
    stdout.writeln('> Loading backend exercises...');
    final backend = await _allExercises(token);
    stdout.writeln('  backend exercises: ${backend.length}');
    stdout.writeln('');
    stdout.writeln('> Backfilling (only where a value changes)...');

    var matched = 0, updated = 0, unchanged = 0, unmatched = 0, failed = 0;
    var previews = 0;
    for (final entry in backend.entries) {
      final name = entry.key;
      final dto = entry.value;
      final src = srcByName[name];
      if (src == null) {
        unmatched++;
        continue;
      }
      matched++;

      final newMuscle = _mapMuscle(src);
      final newEquip = _mapEquipment(src);
      final curMuscle = _asInt(dto['targetMuscle']);
      final curEquip = _asInt(dto['equipment']);
      if (newMuscle == curMuscle && newEquip == curEquip) {
        unchanged++;
        continue;
      }

      if (dryRun) {
        updated++;
        if (previews < 15) {
          previews++;
          stdout.writeln('  [dry] "${dto['name']}"'
              '  muscle ${_mName(curMuscle)}->${_mName(newMuscle)}'
              '  equip ${_eName(curEquip)}->${_eName(newEquip)}');
        }
        continue;
      }

      // PUT the FULL current DTO with only the two enum fields overridden, so
      // instructions/imageUrl/name/etc. are preserved.
      final body = <String, dynamic>{
        'name': dto['name'],
        'description': dto['description'],
        'instructions': dto['instructions'],
        'targetMuscle': newMuscle,
        'equipment': newEquip,
        'videoUrl': dto['videoUrl'],
        'imageUrl': dto['imageUrl'],
        'isActive': dto['isActive'] ?? true,
      };
      try {
        await _api('PUT', 'api/app/exercise/${dto['id']}', jsonBody: body, token: token);
        updated++;
        if (updated % 50 == 0) stdout.writeln('  ...$updated updated');
      } catch (e) {
        failed++;
        if (failed <= 10) stderr.writeln('  FAIL "${dto['name']}": $e');
      }
    }

    stdout.writeln('');
    stdout.writeln('=== Backfill summary ===');
    stdout.writeln('  backend exercises : ${backend.length}');
    stdout.writeln('  matched to source : $matched');
    stdout.writeln('  ${dryRun ? "would update" : "updated"}       : $updated');
    stdout.writeln('  already correct   : $unchanged');
    stdout.writeln('  no source match   : $unmatched');
    stdout.writeln('  failed            : $failed');
    stdout.writeln(dryRun ? 'DRY RUN — nothing was written.' : 'Done.');
  } catch (e) {
    stderr.writeln('BACKFILL FAILED: $e');
    exitCode = 1;
  } finally {
    _http.close(force: true);
  }
}
