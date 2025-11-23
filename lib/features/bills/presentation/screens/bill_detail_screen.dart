import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bills_provider.dart';
import '../../models/bill_model.dart';
import '../../../settings/providers/locale_provider.dart';
import 'bill_form_screen.dart';
import 'package:intl/intl.dart';

class BillDetailScreen extends ConsumerWidget {
  final Bill bill;
  const BillDetailScreen({super.key, required this.bill});

  // Helper translate kategori di detail (sama kayak di form)
  String _getCategoryLabel(String catId, bool isIndo) {
    if (!isIndo) {
      switch (catId) {
        case 'PDAM': return 'Water';
        case 'PLN': return 'Electricity';
        case 'Pendidikan': return 'Education';
        case 'Lainnya': return 'Others';
        default: return catId;
      }
    }
    return catId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final repo = ref.watch(billRepositoryProvider);
    
    // 1. AMBIL BAHASA
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    // 2. KAMUS KATA
    final labels = {
      'amount': isIndo ? 'Jumlah' : 'Amount',
      'due_date': isIndo ? 'Jatuh tempo' : 'Due date',
      'category': isIndo ? 'Kategori' : 'Category',
      'notes': isIndo ? 'Catatan' : 'Notes',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(bill.title), 
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BillFormScreen(bill: bill))),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final user = auth.currentUser!;
              await repo.deleteBill(user.uid, bill.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          )
        ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(bill.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          
          // Format Uang (Rp / $)
          Text('${labels['amount']}: ${NumberFormat.simpleCurrency(locale: isIndo ? 'id_ID' : 'en_US').format(bill.amount)}'),
          
          const SizedBox(height: 8),
          
          // Format Tanggal
          Text('${labels['due_date']}: ${DateFormat.yMMMd(currentLocale.languageCode).format(bill.dueDate)}'),
          
          const SizedBox(height: 8),
          
          // Kategori (Translate jika perlu)
          Text('${labels['category']}: ${_getCategoryLabel(bill.category, isIndo)}'),
          
          if (bill.notes != null && bill.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('${labels['notes']}:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(bill.notes!),
          ],
        ]),
      ),
    );
  }
}