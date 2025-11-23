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
          )
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Belum ada tagihan'),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillFormScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Tagihan'),
                )
              ]),
            );
          }
          return ListView.separated(
            itemCount: bills.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final b = bills[i];
              return ListTile(
                title: Text(b.title),
                subtitle: Text('${DateFormat.yMMMd().format(b.dueDate)} • ${b.category}'),
                trailing: Text(NumberFormat.simpleCurrency().format(b.amount)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BillDetailScreen(bill: b))),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
