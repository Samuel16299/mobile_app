import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bills_provider.dart';
import '../../models/bill_model.dart';
import 'bill_form_screen.dart';

class BillDetailScreen extends ConsumerWidget {
  final Bill bill;
  const BillDetailScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final repo = ref.watch(billRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(bill.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BillFormScreen(bill: bill)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              // Tambahkan dialog konfirmasi sederhana agar aman
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Tagihan?'),
                  content: Text('Yakin ingin menghapus ${bill.title}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final user = auth.currentUser!;
                await repo.deleteBill(user.uid, bill.id);
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bill.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Format Uang (Rupiah)
            Text(
              'Jumlah: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(bill.amount)}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            // Format Tanggal (Indonesia)
            Text(
              'Jatuh tempo: ${DateFormat.yMMMd('id_ID').format(bill.dueDate)}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 8),

            // Kategori
            Text(
              'Kategori: ${bill.category}',
              style: const TextStyle(fontSize: 16),
            ),

            if (bill.notes != null && bill.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Catatan:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                bill.notes!,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ],
        ),
      ),
    );
  }
}