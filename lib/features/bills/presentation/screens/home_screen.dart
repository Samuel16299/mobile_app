import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/bills_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/bill_model.dart';
import 'bill_detail_screen.dart';
import 'bill_form_screen.dart';
import '../../../settings/providers/locale_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategory;
  bool _isTotalVisible = true;

  Widget _buildTotalBalanceCard(
    AsyncValue<List<Bill>> billsAsync,
    NumberFormat formatter,
  ) {
    // Menghitung total tagihan yang belum dibayar
    final double totalAmount = billsAsync.maybeWhen(
      data: (bills) => bills
          .where((b) => !b.isPaid) // Ambil yang belum lunas
          .fold(0.0, (sum, item) => sum + item.amount), // Jumlahkan
      orElse: () => 0.0,
    );

    // Menghitung jumlah item yang belum lunas
    final int unpaidCount = billsAsync.maybeWhen(
      data: (bills) => bills.where((b) => !b.isPaid).length,
      orElse: () => 0,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24), // Jarak ke bawah (ke kategori)
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Desain Gradasi Biru agar terlihat modern
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF0073E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan Anda',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Tombol Mata (Hide/Show)
              InkWell(
                onTap: () {
                  setState(() {
                    _isTotalVisible = !_isTotalVisible;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    _isTotalVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Teks Nominal Uang
          Text(
            _isTotalVisible
                ? formatter.format(totalAmount)
                : 'Rp * * * * * * *', // Sensor jika disembunyikan
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Info tambahan kecil di bawah
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$unpaidCount tagihan belum lunas',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI BARU: MENAMPILKAN POPUP RINGKASAN ---
  void _showSummaryPopup(BuildContext context, List<Bill> allBills) {
    // 1. Filter Data
    final unpaidBills = allBills.where((b) => !b.isPaid).toList();
    final paidBills = allBills.where((b) => b.isPaid).toList();

    // 2. Hitung Total Tagihan (Yang belum dibayar)
    double totalUnpaid = 0;
    for (var bill in unpaidBills) {
      totalUnpaid += bill.amount;
    }

    // Formatter Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 500, // Tinggi popup
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER POPUP ---
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // --- BAGIAN 1: TOTAL YANG HARUS DIBAYAR ---
              const Text(
                'Total Tagihan Aktif',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      currencyFormatter.format(totalUnpaid),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unpaidBills.length} tagihan belum lunas',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- BAGIAN 2: DAFTAR YANG SUDAH LUNAS ---
              const Text(
                'Riwayat Lunas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: paidBills.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tagihan lunas',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.separated(
                        itemCount: paidBills.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final bill = paidBills[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 16,
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              bill.title,
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Text(
                              currencyFormatter.format(bill.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authServiceProvider);
    final user = auth.currentUser;
    final billsAsync = ref.watch(billsStreamProvider);
    final billsController = ref.watch(billsControllerProvider);

    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    final labels = {
      'header': isIndo ? 'Jangan lupa bayar!' : "Don't forget to pay!",
      'hello': isIndo ? 'Halo' : 'Hello',
      'categories_title': isIndo ? 'Daftar catatan' : 'Categories',
      'reset': isIndo ? 'Hapus Filter' : 'Reset Filter',
      'list_title': isIndo ? 'Daftar Pembayaran' : 'Payment List',
      'payment': isIndo ? 'Pembayaran' : 'Payment',
      'empty_list': isIndo
          ? 'Belum ada catatan pembayaran'
          : 'No payment records yet',
      'empty_filter': isIndo ? 'Tidak ada tagihan' : 'No bills for',
      'due_date': isIndo ? 'Jatuh tempo' : 'Due date',
      'logout_tooltip': isIndo ? 'Keluar' : 'Logout',
      'settings_tooltip': isIndo ? 'Pengaturan' : 'Settings',
      'confirm_title': isIndo ? 'Konfirmasi' : 'Confirm',
      'confirm_logout': isIndo
          ? 'Yakin ingin keluar dari aplikasi?'
          : 'Are you sure you want to log out?',
      'cancel': isIndo ? 'Batal' : 'Cancel',
      'logout': isIndo ? 'Keluar' : 'Logout',
      'logout_success': isIndo ? 'Berhasil keluar' : 'Logged out',
      'logout_failed': isIndo ? 'Gagal keluar' : 'Failed to logout',
    };

    final categories = [
      {
        'id': 'PDAM',
        'label': isIndo ? 'PDAM' : 'Water',
        'image': 'assets/images/PDAM.png',
      },
      {
        'id': 'PLN',
        'label': isIndo ? 'PLN' : 'Electricity',
        'image': 'assets/images/PLN.png',
      },
      {
        'id': 'Pendidikan',
        'label': isIndo ? 'Pendi dikan' : 'Education',
        'image': 'assets/images/Pendidikan.png',
      },
      {
        'id': 'Internet',
        'label': isIndo ? 'Internet' : 'Internet',
        'image': 'assets/images/Wifi.png',
      },
    ];

    final currencyLocale = isIndo ? 'id_ID' : 'en_US';
    final dateLocale = isIndo ? 'id_ID' : 'en_US';
    final currencySymbol = isIndo ? 'Rp' : 'Rp';
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: labels['logout_tooltip'],
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(labels['confirm_title']!),
                content: Text(labels['confirm_logout']!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(labels['cancel']!),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      labels['logout']!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              final auth = ref.read(authServiceProvider);
              try {
                await auth.logout();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(labels['logout_success']!),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(labels['logout_failed']!)),
                );
              }
            }
          },
        ),
        actions: [
          // --- MODIFIKASI: Tombol Notifikasi (Lonceng) ---
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Mengambil data bills saat ini dari provider (jika sudah di-load)
              billsAsync.whenData((bills) {
                _showSummaryPopup(context, bills);
              });
            },
          ),
          // -----------------------------------------------
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: labels['settings_tooltip'],
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FBFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            labels['header']!,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user != null
                                ? '${labels['hello']}, ${user.email}'
                                : '${labels['hello']}, user',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_outlined,
                        size: 32,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _buildTotalBalanceCard(billsAsync, currencyFormatter),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labels['categories_title']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (_selectedCategory != null)
                    TextButton(
                      onPressed: () => setState(() => _selectedCategory = null),
                      child: Text(
                        labels['reset']!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BillFormScreen(),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 24),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final id = cat['id'] as String;
                    final label = cat['label'] as String;
                    final isSelected = _selectedCategory == id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_selectedCategory == id) {
                            _selectedCategory = null;
                          } else {
                            _selectedCategory = id;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 92,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blueAccent
                              : const Color(0xFFDFF7F7),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: Colors.blue.shade800,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  cat['image'] as String,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  cacheWidth: 200,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == null
                        ? labels['list_title']!
                        : '${labels['payment']} ($_selectedCategory)',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              billsAsync.when(
                data: (bills) {
                  var filteredBills = bills;
                  if (_selectedCategory != null) {
                    filteredBills = bills
                        .where((b) => b.category == _selectedCategory)
                        .toList();
                  }

                  if (filteredBills.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedCategory == null
                                  ? labels['empty_list']!
                                  : '${labels['empty_filter']} $_selectedCategory',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final recent = filteredBills.reversed.toList();

                  return Column(
                    children: recent.map((b) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Card(
                          elevation: 0,
                          color: b.isPaid
                              ? Colors.green[50]
                              : const Color(0xFFF5F6FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            leading: Checkbox(
                              value: b.isPaid,
                              onChanged: (val) async {
                                if (val != null) {
                                  try {
                                    await billsController.toggleStatus(
                                      b.id,
                                      val,
                                    );
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Update failed: $e'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            title: Text(
                              b.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: b.isPaid
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: b.isPaid ? Colors.grey : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${labels['due_date']}: ${DateFormat.yMMMd(dateLocale).format(b.dueDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  NumberFormat.currency(
                                    locale: currencyLocale,
                                    symbol: currencySymbol,
                                    decimalDigits: 0,
                                  ).format(b.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BillFormScreen(bill: b),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Hapus?'),
                                        content: Text(
                                          'Yakin hapus ${b.title}?',
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
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BillDetailScreen(bill: b),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Error: $e'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
