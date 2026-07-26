import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ApkUpdater {
  Future<void> downloadAndInstall(String apkUrl) async {
    final response = await http.get(Uri.parse(apkUrl));
    if (response.statusCode != 200) {
      throw Exception('No se pudo descargar la actualización (HTTP ${response.statusCode})');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dota-schedule-update.apk');
    await file.writeAsBytes(response.bodyBytes);

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}
