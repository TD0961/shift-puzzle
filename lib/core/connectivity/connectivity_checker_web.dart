import 'package:web/web.dart' as web;

Future<bool> checkPlatformConnectivity() async {
  try {
    return web.window.navigator.onLine;
  } catch (_) {
    return true;
  }
}
