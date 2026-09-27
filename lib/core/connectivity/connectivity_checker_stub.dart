import 'dart:async';
import 'dart:io';

Future<bool> checkPlatformConnectivity() async {
  // In headless automated test runners, default to online to avoid flaky DNS socket calls.
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return true;
  }

  try {
    // 1. Fast interface check: if there are no non-loopback network interfaces,
    // device is clearly disconnected (e.g. Airplane mode, Wi-Fi & cellular disabled).
    final interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.any,
    );
    if (interfaces.isEmpty) {
      return false;
    }

    // 2. DNS reachability check with a short timeout to prevent UI lag.
    final lookup = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 2));
    return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  } on TimeoutException catch (_) {
    return false;
  } catch (_) {
    return false;
  }
}
