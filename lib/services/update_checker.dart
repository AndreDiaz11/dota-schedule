import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrlWindows;
  final String downloadUrlAndroid;
  final String releaseUrl;

  const UpdateInfo({
    required this.latestVersion,
    required this.downloadUrlWindows,
    required this.downloadUrlAndroid,
    required this.releaseUrl,
  });
}

class UpdateChecker {
  static const _repo = 'AndreDiaz11/dota-schedule';

  Future<UpdateInfo?> checkForUpdate() async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;

    final response = await http.get(
      Uri.parse('https://api.github.com/repos/$_repo/releases/latest'),
      headers: {'Accept': 'application/vnd.github+json'},
    );
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String? ?? '').replaceFirst('v', '');
    if (tag.isEmpty || !_isNewer(tag, currentVersion)) return null;

    final assets = data['assets'] as List<dynamic>? ?? [];
    String? apkUrl;
    String? exeUrl;
    for (final asset in assets) {
      final name = asset['name'] as String? ?? '';
      final url = asset['browser_download_url'] as String?;
      if (url == null) continue;
      if (name.endsWith('.apk')) apkUrl = url;
      if (name.endsWith('.zip')) exeUrl = url;
    }

    final releaseUrl = data['html_url'] as String? ?? 'https://github.com/$_repo/releases/latest';
    return UpdateInfo(
      latestVersion: tag,
      downloadUrlWindows: exeUrl ?? releaseUrl,
      downloadUrlAndroid: apkUrl ?? releaseUrl,
      releaseUrl: releaseUrl,
    );
  }

  bool _isNewer(String remote, String local) {
    List<int> parse(String v) => v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final r = parse(remote);
    final l = parse(local);
    for (var i = 0; i < 3; i++) {
      final rv = i < r.length ? r[i] : 0;
      final lv = i < l.length ? l[i] : 0;
      if (rv != lv) return rv > lv;
    }
    return false;
  }
}
