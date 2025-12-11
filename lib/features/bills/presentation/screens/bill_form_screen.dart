import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bill_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bills_provider.dart';
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

  final List<String> _categoriesIds = [
    'PDAM',
    'PLN',
    'Pendidikan',
    'Internet',
    'Lainnya',
  ];

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

  Future<void> _submit() async {
    // Teks dalam Bahasa Indonesia permanen
    const errorMsg = 'Lengkapi form dan pilih tanggal';
    const errorSave = 'Gagal: ';
    const timeoutMsg = 'Request timeout, coba lagi nanti.';

    if (!_formKey.currentState!.validate() || dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(errorMsg)),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final billData = Bill(
        id: widget.bill?.id ?? '',
        title: title,
        amount: amount,
        dueDate: dueDate!,
        category: category,
        notes: notes,
        repeat: repeat,
        userId: user.uid,
        createdAt: widget.bill?.createdAt ?? Timestamp.now(),
        isPaid: widget.bill?.isPaid ?? false,
      );

      final billsController = ref.read(billsControllerProvider);

      if (widget.bill == null) {
        await billsController.addBill(billData);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Berhasil disimpan')),
        );
        navigator.pop();
      } else {
        await billsController.editBill(billData);
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Perubahan tersimpan')),
        );
        navigator.pop();
      }
    } on TimeoutException {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text(timeoutMsg)));
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$errorSave $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bill == null ? 'Tambah Tagihan' : 'Edit Tagihan',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- Judul ---
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Judul'),
                onChanged: (v) => title = v,
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Wajib diisi',
              ),
              const SizedBox(height: 8),

              // --- Jumlah ---
              TextFormField(
                initialValue: amount == 0.0 ? '' : amount.toStringAsFixed(0),
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                onChanged: (v) => amount = double.tryParse(v) ?? 0.0,
                validator: (v) => (v != null && double.tryParse(v) != null)
                    ? null
                    : 'Masukkan angka',
              ),
              const SizedBox(height: 8),

              // --- Tanggal ---
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  dueDate == null
                      ? 'Pilih Tanggal Jatuh Tempo'
                      : DateFormat.yMMMd('id_ID').format(dueDate!),
                  style: TextStyle(
                    color: dueDate == null ? Colors.grey[700] : Colors.black,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    locale: const Locale('id', 'ID'), // Paksa Locale Indo
                  );
                  if (picked != null) {
                    setState(() => dueDate = picked);
                  }
                },
              ),
              const Divider(),
              const SizedBox(height: 8),

              // --- Kategori ---
              DropdownButtonFormField<String>(
                initialValue:
                    _categoriesIds.contains(category) ? category : null,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: UnderlineInputBorder(),
                ),
                items: _categoriesIds.map((String catId) {
                  return DropdownMenuItem<String>(
                    value: catId,
                    child: Row(
                      children: [
                        Icon(
                          catId == 'PDAM'
                              ? Icons.water_drop_outlined
                              : catId == 'PLN'
                                  ? Icons.electric_bolt_outlined
                                  : catId == 'Pendidikan'
                                      ? Icons.school_outlined
                                      : catId == 'Internet'
                                          ? Icons.wifi
                                          : Icons.category_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(catId), // Langsung pakai nama kategori
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    category = newValue ?? 'Lainnya';
                  });
                },
                validator: (value) => value == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),

              // --- Notes ---
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(labelText: 'Catatan'),
                onChanged: (v) => notes = v,
              ),
              const SizedBox(height: 24),

              // --- Tombol Simpan ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}