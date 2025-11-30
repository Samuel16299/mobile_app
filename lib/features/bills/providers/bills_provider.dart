import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bill_repository.dart';
import '../models/bill_model.dart';
import 'auth_provider.dart';
import '../../../core/service/notification_service.dart';

// 1. Provider untuk NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// 2. Provider untuk Repository (BAGIAN INI YANG HILANG SEBELUMNYA)
final billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepository(),
);

// 3. Provider untuk Stream Bills (List Tagihan)
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

// 4. Provider untuk Controller
final billsControllerProvider = Provider<BillsController>((ref) {
  final repo = ref.watch(billRepositoryProvider);
  final auth = ref.watch(authStateProvider);
  final notifService = ref.watch(notificationServiceProvider); 

  final String uid = auth.value?.uid ?? '';

  return BillsController(
    repo: repo, 
    uid: uid,
    notifService: notifService,
  );
});

// 5. Class Controller Logika Utama
class BillsController {
  final BillRepository repo;
  final String uid;
  final NotificationService notifService;

  BillsController({
    required this.repo, 
    required this.uid,
    required this.notifService,
  });

  // Helper: Ubah String ID (Firestore) jadi int (Notifikasi)
  int _generateIntId(String id) {
    return id.hashCode;
  }

  Future<void> addBill(Bill bill) async {
    if (uid.isEmpty) return;
    // Simpan & dapatkan ID baru
    final newId = await repo.createBill(bill);
    
    // Jadwalkan notifikasi
    await notifService.scheduleNotification(
      id: _generateIntId(newId),
      title: 'Tagihan Jatuh Tempo!',
      body: 'Jangan lupa bayar tagihan: ${bill.title}',
      date: bill.dueDate,
    );
  }

  Future<void> editBill(Bill bill) async {
    if (uid.isEmpty) return;
    await repo.updateBill(bill);

    // Update notifikasi
    await notifService.scheduleNotification(
      id: _generateIntId(bill.id),
      title: 'Tagihan Jatuh Tempo!',
      body: 'Jangan lupa bayar tagihan: ${bill.title}',
      date: bill.dueDate,
    );
  }

  Future<void> deleteBill(String billId) async {
    if (uid.isEmpty) return;
    await repo.deleteBill(uid, billId);
    
    // Hapus notifikasi
    await notifService.cancelNotification(_generateIntId(billId));
  }

  Future<void> toggleStatus(String billId, bool isPaid) async {
    if (uid.isEmpty) return;
    await repo.updateBillStatus(uid, billId, isPaid);

    if (isPaid) {
      // Batalkan notifikasi kalau sudah lunas
      await notifService.cancelNotification(_generateIntId(billId));
    }
  }
}