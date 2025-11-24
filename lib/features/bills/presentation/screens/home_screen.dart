import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/bills_provider.dart';
import '../../providers/auth_provider.dart';
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
  // Variabel untuk menyimpan kategori yang sedang dipilih
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authServiceProvider);
    final user = auth.currentUser;
    final billsAsync = ref.watch(billsStreamProvider);
    final billsController = ref.watch(billsControllerProvider);

    // 1. AMBIL STATUS BAHASA SAAT INI
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    // 2. (Terjemahan Home)
    final labels = {
      'header': isIndo ? 'Jangan lupa bayar!' : "Don't forget to pay!",
      'hello': isIndo ? 'Halo' : 'Hello',
      'categories_title': isIndo ? 'Daftar catatan' : 'Categories',
      'reset': isIndo ? 'Hapus Filter' : 'Reset Filter',
      'list_title': isIndo ? 'Daftar Pembayaran' : 'Payment List',
      'payment': isIndo ? 'Pembayaran' : 'Payment',
      'empty_list': isIndo ? 'Belum ada catatan pembayaran' : 'No payment records yet',
      'empty_filter': isIndo ? 'Tidak ada tagihan' : 'No bills for',
      'due_date': isIndo ? 'Jatuh tempo' : 'Due date',
      'logout_tooltip': isIndo ? 'Keluar' : 'Logout',
      'settings_tooltip': isIndo ? 'Pengaturan' : 'Settings',
      'confirm_title': isIndo ? 'Konfirmasi' : 'Confirm',
      'confirm_logout': isIndo ? 'Yakin ingin keluar dari aplikasi?' : 'Are you sure you want to log out?',
      'cancel': isIndo ? 'Batal' : 'Cancel',
      'logout': isIndo ? 'Keluar' : 'Logout',
      'logout_success': isIndo ? 'Berhasil keluar' : 'Logged out',
      'logout_failed': isIndo ? 'Gagal keluar' : 'Failed to logout',
    };

    // 3. DATA KATEGORI (Icon & Label Terjemahan)
    final categories = [
      {
        'id': 'PDAM',
        'label': isIndo ? 'PDAM' : 'Water',
        'icon': Icons.water_drop_outlined,
      },
      {
        'id': 'PLN',
        'label': isIndo ? 'PLN' : 'Electricity',
        'icon': Icons.electric_bolt_outlined,
      },
      {
        'id': 'Pendidikan',
        'label': isIndo ? 'Pendidikan' : 'Education',
        'icon': Icons.school_outlined,
      },
      {
        'id': 'Internet',
        'label': isIndo ? 'Internet' : 'Internet',
        'icon': Icons.wifi,
      },
    ];

    // Helper: choose correct locale strings for intl package
    final currencyLocale = isIndo ? 'id_ID' : 'en_US';
    final dateLocale = isIndo ? 'id_ID' : 'en_US';
    final currencySymbol = isIndo ? 'Rp': 'Rp';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Tombol Logout
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
                // optional: navigate to login
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(labels['logout_failed']!),
                  ),
                );
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          // Tombol Setting
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
              // --- HEADER USER ---
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
                            user != null ? '${labels['hello']}, ${user.email}' : '${labels['hello']}, user',
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

              // --- BAGIAN PILIHAN KATEGORI (FILTER) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    labels['categories_title']!,
                    style: theme.textTheme.titleMedium,
                  ),
                  // Jika filter aktif, tampilkan tombol Reset
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

              // List Horizontal Kategori
              SizedBox(
                height: 96,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
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
                          color: isSelected ? Colors.blueAccent : const Color(0xFFDFF7F7),
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
                              radius: 22,
                              backgroundColor: Colors.white,
                              child: Icon(
                                cat['icon'] as IconData,
                                color: isSelected ? Colors.blueAccent : Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

              // --- DAFTAR TAGIHAN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == null ? labels['list_title']! : '${labels['payment']} ($_selectedCategory)',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              billsAsync.when(
                data: (bills) {
                  var filteredBills = bills;

                  // FILTER DATA
                  if (_selectedCategory != null) {
                    filteredBills = bills.where((b) => b.category == _selectedCategory).toList();
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
                              _selectedCategory == null ? labels['empty_list']! : '${labels['empty_filter']} $_selectedCategory',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
                          // Ubah warna card jika lunas
                          color: b.isPaid ? Colors.green[50] : const Color(0xFFF5F6FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

                            // [FITUR 1] CHECKBOX LUNAS
                            leading: Checkbox(
                              value: b.isPaid,
                              onChanged: (val) async {
                                if (val != null) {
                                  try {
                                    await billsController.toggleStatus(b.id, val);
                                  } catch (e) {
                                    // show simple feedback
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Update failed: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),

                            // [FITUR 2]JUDUL
                            title: Text(
                              b.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: b.isPaid ? TextDecoration.lineThrough : null,
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

                            // [FITUR 3] TOMBOL EDIT & HAPUS
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // EDIT
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
                                // HAPUS
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
                                        content: Text('Yakin hapus ${b.title}?'),
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
