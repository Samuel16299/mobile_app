import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bill_repository.dart';
import '../models/bill_model.dart';
import 'auth_provider.dart';

final billRepositoryProvider = Provider<BillRepository>((ref) => BillRepository());

final billsStreamProvider = StreamProvider.autoDispose<List<Bill>>((ref) {
  final userAsync = ref.watch(authStateProvider);
  final repo = ref.watch(billRepositoryProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      return repo.streamBills(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
