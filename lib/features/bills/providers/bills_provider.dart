import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bill_repository.dart';
import '../models/bill_model.dart';
import 'auth_provider.dart';

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepository(),
);

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

final billsControllerProvider = Provider<BillsController>((ref) {
  final repo = ref.watch(billRepositoryProvider);
  final userAsync = ref.watch(authStateProvider);

  final String uid = userAsync.value?.uid ?? '';

  return BillsController(repo: repo, uid: uid);
});

class BillsController {
  final BillRepository repo;
  final String uid;

  BillsController({required this.repo, required this.uid});

  // Fitur: Tambah Tagihan
  Future<void> addBill(Bill bill) async {
    if (uid.isEmpty) return; // Guard clause
    await repo.createBill(bill);
  }

  // Fitur: Edit Tagihan (Update Full)
  Future<void> editBill(Bill bill) async {
    if (uid.isEmpty) return;
    await repo.updateBill(bill);
  }

  // Fitur: Hapus Tagihan
  Future<void> deleteBill(String billId) async {
    if (uid.isEmpty) return;
    await repo.deleteBill(uid, billId);
  }

  // Fitur: Tandai Lunas (Update Status)
  Future<void> toggleStatus(String billId, bool isPaid) async {
    if (uid.isEmpty) return;
    await repo.updateBillStatus(uid, billId, isPaid);
  }
}
