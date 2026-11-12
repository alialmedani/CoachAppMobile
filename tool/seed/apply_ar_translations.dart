// CoachApp — apply Arabic exercise-instruction translations (one-off seed).
//
// Reads `translated_*.json` files (each a JSON array of {id, ar}) produced by the
// translation pass, and writes them to the backend Exercise via PUT:
//   InstructionsAr        = ar   (the editable Arabic shown in the app)
//   InstructionsArOriginal = ar  (the write-once machine-translation snapshot)
//
// The full current DTO is re-sent with only the two Arabic fields overridden, so
// name/description/instructions/imageUrl/muscle/equipment are preserved. The
// backend keeps InstructionsArOriginal write-once, so re-running never clobbers a
// coach's later edits. Idempotent: skips an exercise whose InstructionsArOriginal
// is already set.
//
// Run from the repo root against a RUNNING backend (after the migration is applied):
//   dart run tool/seed/apply_ar_translations.dart
//
// Config (env; defaults match the demo tenant): API_BASE_URL, COACHAPP_TENANT,
// COACHAPP_COACH_USER, COACHAPP_COACH_PASS, XLATE_DIR (folder with translated_*.json).
import 'dart:convert';
import 'dart:io';

String _env(String key, String fallback) {
  final v = Platform.environment[key];
  return (v != null && v.isNotEmpty) ? v : fallback;
}

String _slash(String s) => s.endsWith('/') ? s : '$s/';

final String baseUrl = _slash(_env('API_BASE_URL', 'https://localhost:44370/'));
final String tenant = _env('COACHAPP_TENANT', 'demo');
final String coachUser = _env('COACHAPP_COACH_USER', 'admin');
final String coachPass = _env('COACHAPP_COACH_PASS', '1q2w3E*');
const String clientId = 'CoachApp_App';
const String scope = 'CoachApp offline_access profile email phone roles';
final String xlateDir = _env(
  'XLATE_DIR',
  r'C:\Users\alime\AppData\Local\Temp\claude\C--src-APP-CoachAppMobile-coachappmobile\83f57525-7be0-458e-9015-b6ac801dd328\scratchpad\xlate',
);

final HttpClient _http = _makeHttpClient();
HttpClient _makeHttpClient() {
  final c = HttpClient();
  c.badCertificateCallback = (cert, host, port) => true;
  c.connectionTimeout = const Duration(seconds: 30);
  return c;
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
  final snip = text.length > 300 ? '${text.substring(0, 300)}…' : text;
  throw '$method $path -> ${resp.statusCode}: $snip';
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
  if (t == null || t.isEmpty) throw 'login failed';
  return t;
}

Future<void> main() async {
  stdout.writeln('CoachApp Arabic-translation apply');
  stdout.writeln('  base: $baseUrl  tenant: $tenant  xlateDir: $xlateDir');

  // 1) Merge all translated_*.json into id -> ar.
  final dir = Directory(xlateDir);
  if (!dir.existsSync()) {
    stderr.writeln('XLATE_DIR not found: $xlateDir');
    exitCode = 1;
    return;
  }
  final byId = <String, String>{};
  var files = 0;
  for (final f in dir.listSync().whereType<File>()) {
    final base = f.uri.pathSegments.last;
    if (!(base.startsWith('translated_') && base.endsWith('.json'))) continue;
    files++;
    final data = jsonDecode(await f.readAsString()) as List;
    for (final row in data) {
      final m = (row as Map).cast<String, dynamic>();
      final id = m['id']?.toString();
      final ar = m['ar']?.toString();
      if (id != null && id.isNotEmpty && ar != null && ar.trim().isNotEmpty) {
        byId[id] = ar;
      }
    }
  }
  stdout.writeln('  merged $files file(s) → ${byId.length} translations');
  if (byId.isEmpty) {
    stderr.writeln('nothing to apply');
    return;
  }

  // 2) Auth.
  stdout.writeln('> Authenticating as coach...');
  final token = await _login();

  // 3) For each translation: GET current DTO, skip if original already set, else PUT.
  var applied = 0, skipped = 0, failed = 0, missing = 0, i = 0;
  for (final entry in byId.entries) {
    i++;
    final id = entry.key;
    final ar = entry.value;
    try {
      final dto = await _api('GET', 'api/app/exercise/$id', token: token) as Map;
      final existingOrig = (dto['instructionsArOriginal'] as String?)?.trim() ?? '';
      if (existingOrig.isNotEmpty) {
        skipped++;
        continue;
      }
      final body = <String, dynamic>{
        'name': dto['name'],
        'description': dto['description'],
        'instructions': dto['instructions'],
        'instructionsAr': ar,
        'instructionsArOriginal': ar,
        'targetMuscle': dto['targetMuscle'] ?? 0,
        'equipment': dto['equipment'] ?? 0,
        'videoUrl': dto['videoUrl'],
        'imageUrl': dto['imageUrl'],
        'isActive': dto['isActive'] ?? true,
      };
      await _api('PUT', 'api/app/exercise/$id', jsonBody: body, token: token);
      applied++;
      if (applied % 50 == 0) stdout.writeln('  ...$applied applied (scanned $i)');
    } catch (e) {
      // A 404 means the id isn't in this tenant (shouldn't happen); count it.
      if (e.toString().contains('-> 404')) {
        missing++;
      } else {
        failed++;
        if (failed <= 10) stderr.writeln('  FAIL $id: $e');
      }
    }
  }

  stdout.writeln('');
  stdout.writeln('=== Apply summary ===');
  stdout.writeln('  translations     : ${byId.length}');
  stdout.writeln('  applied          : $applied');
  stdout.writeln('  skipped(has orig): $skipped');
  stdout.writeln('  missing(404)     : $missing');
  stdout.writeln('  failed           : $failed');
  stdout.writeln('Done.');
  _http.close(force: true);
}
