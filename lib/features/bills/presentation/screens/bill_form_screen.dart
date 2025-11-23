import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bill_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bills_provider.dart';
import '../../../settings/providers/locale_provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillFormScreen extends ConsumerStatefulWidget {
  final Bill? bill;
  const BillFormScreen({super.key, this.bill});

  @override
  ConsumerState<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends ConsumerState<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String title = '';
  double amount = 0.0;
  DateTime? dueDate;
  String category = 'Lainnya'; 
  String repeat = 'none';
  String? notes;
  bool _loading = false;

  // Karena kategori disimpan di database, ID-nya (value) jangan diterjemahkan.
  // Yang diterjemahkan hanya tampilannya (child text).
  final List<String> _categoriesIds = ['PDAM', 'PLN', 'Pendidikan', 'Internet', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.bill != null) {
      title = widget.bill!.title;
      amount = widget.bill!.amount;
      dueDate = widget.bill!.dueDate;
      category = widget.bill!.category;
      if (!_categoriesIds.contains(category)) {
        category = 'Lainnya';
      }
      repeat = widget.bill!.repeat;
      notes = widget.bill!.notes;
    }
  }

  // Helper untuk menerjemahkan kategori
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

  Future<void> _submit(bool isIndo) async {
    // Pesan validasi juga diterjemahkan
    final errorMsg = isIndo ? 'Lengkapi form dan pilih tanggal' : 'Please complete the form and pick a date';
    final errorSave = isIndo ? 'Gagal: ' : 'Failed: ';

    if (!_formKey.currentState!.validate() || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final repo = ref.read(billRepositoryProvider);
      final user = auth.currentUser;

      if (user == null) throw Exception('User not logged in');

      final bill = Bill(
        id: widget.bill?.id ?? '',
        title: title,
        amount: amount,
        dueDate: dueDate!,
        category: category,
        notes: notes,
        repeat: repeat,
        userId: user.uid,
        createdAt: widget.bill?.createdAt ?? Timestamp.now(),
      );

      if (widget.bill == null) {
        await repo.createBill(bill).timeout(const Duration(seconds: 5), onTimeout: () {});
      } else {
        await repo.updateBill(bill).timeout(const Duration(seconds: 5), onTimeout: () {});
      }

      navigator.pop();

    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        messenger.showSnackBar(SnackBar(content: Text('$errorSave $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AMBIL STATUS BAHASA
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    // LABEL TERJEMAHAN
    final labels = {
      'appbar_add': isIndo ? 'Tambah Tagihan' : 'Add Bill',
      'appbar_edit': isIndo ? 'Edit Tagihan' : 'Edit Bill',
      'label_title': isIndo ? 'Judul' : 'Title',
      'label_amount': isIndo ? 'Jumlah' : 'Amount',
      'label_date': isIndo ? 'Pilih Tanggal Jatuh Tempo' : 'Select Due Date',
      'label_category': isIndo ? 'Kategori' : 'Category',
      'label_notes': isIndo ? 'Catatan' : 'Notes',
      'btn_save': isIndo ? 'Simpan' : 'Save',
      'valid_required': isIndo ? 'Wajib diisi' : 'Required',
      'valid_number': isIndo ? 'Masukkan angka' : 'Enter a number',
    };

    return Scaffold(
      appBar: AppBar(title: Text(widget.bill == null ? labels['appbar_add']! : labels['appbar_edit']!)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            // --- Judul ---
            TextFormField(
              initialValue: title,
              decoration: InputDecoration(labelText: labels['label_title']),
              onChanged: (v) => title = v,
              validator: (v) => v != null && v.isNotEmpty ? null : labels['valid_required'],
            ),
            const SizedBox(height: 8),

            // --- Jumlah ---
            TextFormField(
              initialValue: amount == 0.0 ? '' : amount.toStringAsFixed(0),
              decoration: InputDecoration(labelText: labels['label_amount']),
              keyboardType: TextInputType.number,
              onChanged: (v) => amount = double.tryParse(v) ?? 0.0,
              validator: (v) => (v != null && double.tryParse(v) != null) ? null : labels['valid_number'],
            ),
            const SizedBox(height: 8),

            // --- Tanggal ---
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                dueDate == null
                    ? labels['label_date']!
                    // Format tanggal menyesuaikan Locale
                    : DateFormat.yMMMd(currentLocale.languageCode).format(dueDate!),
                style: TextStyle(color: dueDate == null ? Colors.grey[700] : Colors.black),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: currentLocale, // DatePicker pakai bahasa aktif
                );
                if (picked != null) {
                  setState(() => dueDate = picked);
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 8),

            // --- Kategori (Dropdown) ---
            DropdownButtonFormField<String>(
              value: _categoriesIds.contains(category) ? category : null,
              decoration: InputDecoration(
                labelText: labels['label_category'],
                border: const UnderlineInputBorder(),
              ),
              items: _categoriesIds.map((String catId) {
                return DropdownMenuItem<String>(
                  value: catId,
                  child: Row(
                    children: [
                      Icon(
                        catId == 'PDAM' ? Icons.water_drop_outlined :
                        catId == 'PLN' ? Icons.electric_bolt_outlined :
                        catId == 'Pendidikan' ? Icons.school_outlined :
                        catId == 'Internet' ? Icons.wifi : Icons.category_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      // Tampilkan label yang sudah diterjemahkan
                      Text(_getCategoryLabel(catId, isIndo)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  category = newValue ?? 'Lainnya';
                });
              },
              validator: (value) => value == null ? labels['valid_required'] : null,
            ),
            const SizedBox(height: 8),

            // --- Notes ---
            TextFormField(
              initialValue: notes,
              decoration: InputDecoration(labelText: labels['label_notes']),
              onChanged: (v) => notes = v,
            ),
            const SizedBox(height: 24),

            // --- Tombol Simpan ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () => _submit(isIndo),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(labels['btn_save']!),
              ),
            )
          ]),
        ),
      ),
    );
  }
}