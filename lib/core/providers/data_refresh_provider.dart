import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sygnał do odświeżenia danych – wywołaj ref.invalidate(dataRefreshProvider)
/// aby wymusić odświeżenie zależnych providerów.
final dataRefreshProvider = StateProvider<int>((ref) => 0);

/// Helper: invaliduje dataRefreshProvider, co może być nasłuchiwane przez inne providery.
void invalidateData(Ref ref) {
  ref.invalidate(dataRefreshProvider);
}
