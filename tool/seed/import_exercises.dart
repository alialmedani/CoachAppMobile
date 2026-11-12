// CoachApp — one-off importer: free-exercise-db  ->  Exercise library.
//
// Imports ONLY the two things requested: the EXPLANATION (the source's
// step-by-step `instructions`, joined into a numbered how-to) and ONE IMAGE
// (the first photo). Everything else (targetMuscle, equipment, description,
// video, ...) is intentionally left at the server defaults — you set those
// yourself later.
//
// Source: https://github.com/yuhonas/free-exercise-db  (Unlicense / public
// domain, 800+ exercises). Images are served from the jsDelivr CDN.
//
// Run from the repo root against a RUNNING CoachApp backend:
//
//   dart run tool/seed/import_exercises.dart              # import for real
//   DRY_RUN=1 dart run tool/seed/import_exercises.dart    # download+map only, no writes
//
// It uses ONLY the existing REST API (`POST /api/app/exercise`) — the same
// endpoint the app uses — so there is NO backend/schema/migration change. It
// authenticates as the demo tenant's admin ("coach").
//
// SAFE TO RE-RUN: every exercise is skipped if its name already exists
// (case-insensitive), and duplicate names inside the dataset are collapsed.
//
// Config (all overridable via environment variables; defaults match the demo
// tenant): API_BASE_URL, COACHAPP_TENANT, COACHAPP_COACH_USER,
// COACHAPP_COACH_PASS, EXERCISE_DB_URL (dataset), EXERCISE_DB_FILE (local json
// path override, skips the download), IMAGE_CDN_BASE, DRY_RUN (1 = no writes).
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

// OpenIddict public client (mirrors login_params.dart in the app).
const String clientId = 'CoachApp_App';
const String scope = 'CoachApp offline_access profile email phone roles';

// Dataset (combined JSON) + image CDN base. jsDelivr is a real CDN (raw
// .githubusercontent.com is rate-limited and not meant for hotlinking).
final String datasetUrl = _env(
  'EXERCISE_DB_URL',
  'https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/dist/exercises.json',
);
final String localFile = _env('EXERCISE_DB_FILE', '');
final String imageCdnBase = _ensureTrailingSlash(
  _env(
    'IMAGE_CDN_BASE',
    'https://cdn.jsdelivr.net/gh/yuhonas/free-exercise-db@main/exercises',
  ),
);
final bool dryRun = _env('DRY_RUN', '') == '1';

// Backend field caps (mirror ExerciseConsts in the backend).
const int maxName = 128;
const int maxInstructions = 2000;
const int maxUrl = 512;

final HttpClient _http = _makeHttpClient();
HttpClient _makeHttpClient() {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true; // dev self-signed
  client.connectionTimeout = const Duration(seconds: 30);
  return client;
}

// --------------------------------------------------------------------------
// HTTP helpers
// --------------------------------------------------------------------------
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
  });
  final t = (r as Map)['access_token'] as String?;
  if (t == null || t.isEmpty) throw 'login failed: no access_token';
  return t;
}

Future<String> _fetchRaw(String url) async {
  final req = await _http.getUrl(Uri.parse(url));
  req.headers.set(HttpHeaders.acceptHeader, 'application/json');
  final resp = await req.close();
  if (resp.statusCode != 200) throw 'GET $url -> ${resp.statusCode}';
  return resp.transform(utf8.decoder).join();
}

/// All existing exercise names (lowercased) — for idempotency. The list
/// endpoint is paged (ABP PagedResultDto: { items, totalCount }).
Future<Set<String>> _existingNames(String token) async {
  final names = <String>{};
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
      final n = ((e as Map)['name'] as String?)?.trim().toLowerCase();
      if (n != null && n.isNotEmpty) names.add(n);
    }
    final total = (r['totalCount'] as int?) ?? items.length;
    skip += items.length;
    if (items.isEmpty || skip >= total) break;
  }
  return names;
}

/// Join the source `instructions` (a list of steps) into a single numbered
/// how-to string, capped to the backend's 2000-char limit.
String _joinInstructions(List steps) {
  final buf = StringBuffer();
  var n = 0;
  for (final s in steps) {
    final line = s.toString().trim();
    if (line.isEmpty) continue;
    n++;
    if (buf.isNotEmpty) buf.write('\n');
    buf.write('$n. $line');
  }
  var out = buf.toString();
  if (out.length > maxInstructions) out = out.substring(0, maxInstructions);
  return out;
}

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------
Future<void> main() async {
  stdout.writeln('CoachApp exercise importer  (free-exercise-db, Unlicense)');
  stdout.writeln('  base   : $baseUrl');
  stdout.writeln('  tenant : $tenant   coach: $coachUser');
  stdout.writeln('  dryRun : $dryRun');
  stdout.writeln('');

  try {
    // 1) Dataset (local file override, else download).
    String raw;
    if (localFile.isNotEmpty) {
      stdout.writeln('> Reading dataset from file: $localFile');
      raw = await File(localFile).readAsString();
    } else {
      stdout.writeln('> Downloading dataset: $datasetUrl');
      raw = await _fetchRaw(datasetUrl);
    }
    final data = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    stdout.writeln('  dataset entries: ${data.length}');

    // 2) Auth + existing-name set for idempotency.
    stdout.writeln('> Authenticating as coach...');
    final token = await _login();
    stdout.writeln('> Loading existing exercise names...');
    final existing = await _existingNames(token);
    stdout.writeln('  existing exercises: ${existing.length}');
    stdout.writeln('');
    stdout.writeln('> Importing (name + numbered instructions + one image)...');

    var created = 0, skippedExisting = 0, skippedBad = 0, failed = 0, noImage = 0;
    final seen = <String>{}; // in-run dedupe by name
    var i = 0;
    for (final m in data) {
      i++;
      var name = (m['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) {
        skippedBad++;
        continue;
      }
      if (name.length > maxName) name = name.substring(0, maxName);
      final key = name.toLowerCase();
      if (seen.contains(key)) {
        skippedBad++;
        continue;
      }
      seen.add(key);
      if (existing.contains(key)) {
        skippedExisting++;
        continue;
      }

      final instructions = _joinInstructions((m['instructions'] as List?) ?? const []);
      final images = (m['images'] as List?) ?? const [];
      String? imageUrl;
      if (images.isNotEmpty) {
        final candidate = '$imageCdnBase${images.first}';
        imageUrl = candidate.length <= maxUrl ? candidate : null;
      } else {
        noImage++;
      }

      final body = <String, dynamic>{
        'name': name,
        'instructions': instructions,
        'targetMuscle': 0, // other  (you set the real value yourself)
        'equipment': 0, // none
        'isActive': true,
      };
      if (imageUrl != null) body['imageUrl'] = imageUrl;

      if (dryRun) {
        created++;
        if (created <= 5) {
          stdout.writeln(
              '  [dry] "$name"  image=${imageUrl != null}  steps=${(m['instructions'] as List?)?.length ?? 0}');
        }
        continue;
      }
      try {
        await _api('POST', 'api/app/exercise', jsonBody: body, token: token);
        created++;
        if (created % 50 == 0) {
          stdout.writeln('  ...$created created (scanned $i/${data.length})');
        }
      } catch (e) {
        failed++;
        if (failed <= 10) stderr.writeln('  FAIL "$name": $e');
      }
    }

    stdout.writeln('');
    stdout.writeln('=== Import summary ===');
    stdout.writeln('  dataset entries  : ${data.length}');
    stdout.writeln('  created          : $created');
    stdout.writeln('  skipped(existing): $skippedExisting');
    stdout.writeln('  skipped(bad/dupe): $skippedBad');
    stdout.writeln('  imported w/o image: $noImage');
    stdout.writeln('  failed           : $failed');
    stdout.writeln(dryRun ? 'DRY RUN — nothing was written.' : 'Done.');
  } catch (e) {
    stderr.writeln('IMPORT FAILED: $e');
    exitCode = 1;
  } finally {
    _http.close(force: true);
  }
}
