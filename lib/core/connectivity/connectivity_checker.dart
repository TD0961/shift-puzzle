import 'connectivity_checker_stub.dart'
    if (dart.library.js_interop) 'connectivity_checker_web.dart';

Future<bool> checkNetworkConnectivity() => checkPlatformConnectivity();
