import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Licznik wizyt w gałęzi tabów (StatefulShell). Zwiększany przy każdym
/// tapnięciu zakładki — ekrany nasłuchują, by odświeżyć dane.
final mainTabVisitProvider =
    StateProvider.family<int, int>((ref, branchIndex) => 0);

/// Data bez godziny — stabilny klucz Riverpod family (DateTime.now() ma ms).
DateTime dayKey(DateTime d) => DateTime(d.year, d.month, d.day);
