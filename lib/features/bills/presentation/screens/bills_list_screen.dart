import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bills_provider.dart';
import '../../providers/auth_provider.dart';
import 'bill_form_screen.dart';
import 'bill_detail_screen.dart';
import 'package:intl/intl.dart';

class BillsListScreen extends ConsumerWidget {
  const BillsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsStreamProvider);
    final auth = ref.watch(authServiceProvider);
    final billsController = ref.watch(billsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tagihan'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
            },
          ),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Belum ada tagihan'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BillFormScreen()),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Tagihan'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: bills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final b = bills[i];
              final currencyFormatter = NumberFormat.simpleCurrency(
                locale: 'id_ID',
              );
              return ListTile(
                leading: Checkbox(
                  value: b.isPaid, // Mengambil status dari model
                  onChanged: (bool? value) {
                    if (value != null) {
                      // Panggil controller untuk update status di Firebase
                      billsController.toggleStatus(b.id, value);
                    }
                  },
                ),

                // FITUR 2: Judul dicoret jika sudah lunas
                title: Text(
                  b.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: b.isPaid ? TextDecoration.lineThrough : null,
                    color: b.isPaid ? Colors.grey : Colors.black,
                  ),
                ),

                // Subtitle: Tanggal • Kategori • Harga
                // (Harga dipindah ke sini agar muat tombol aksi di kanan)
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat.yMMMd().format(b.dueDate)} • ${b.category}',
                    ),
                    Text(
                      currencyFormatter.format(b.amount),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // FITUR 3: Tombol Aksi (Edit & Hapus) di sebelah kanan
                trailing: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Agar Row tidak memakan tempat berlebih
                  children: [
                    // Tombol Edit
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                        size: 20,
                      ),
                      tooltip: 'Edit',
                      onPressed: () {
                        // Navigasi ke FormScreen dengan membawa data 'b' (Bill)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BillFormScreen(bill: b),
                          ),
                        );
                      },
                    ),
                    // Tombol Hapus
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'Hapus',
                      onPressed: () {
                        // Tampilkan konfirmasi sebelum hapus
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Tagihan?'),
                            content: Text(
                              'Anda yakin ingin menghapus "${b.title}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  billsController.deleteBill(b.id);
                                  Navigator.pop(ctx);
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Klik pada list tile tetap membuka detail (Opsional)
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BillDetailScreen(bill: b)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BillFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
