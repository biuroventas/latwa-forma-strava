import 'dart:io' show Platform;

bool get isIOS => Platform.isIOS;

/// true tylko na symulatorze iOS (nie na prawdziwym urządzeniu).
bool get isIOSSimulator {
  if (!Platform.isIOS) return false;
  return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
      Platform.environment.containsKey('SIMULATOR_UDID') ||
      (Platform.environment['SIMULATOR_HOST_HOME']?.isNotEmpty ?? false);
}

