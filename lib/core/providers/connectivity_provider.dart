import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider stanu połączenia sieciowego.
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Provider bool – true gdy online (WiFi lub mobile data).
final isOnlineProvider = Provider<bool>((ref) {
  final async = ref.watch(connectivityProvider);
  return async.when(
    data: (results) => results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet),
    loading: () => true,
    error: (_, _) => true,
  );
});
