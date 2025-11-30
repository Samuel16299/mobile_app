import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../../bills/providers/bills_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil status bahasa saat ini
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    return Scaffold(
      appBar: AppBar(
        title: Text(isIndo ? 'Pengaturan' : 'Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Title
          Text(
            isIndo ? 'Umum' : 'General',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Card untuk pilihan Bahasa
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Colors.blue),
                  title: Text(isIndo ? 'Bahasa Indonesia' : 'English Language'),
                  trailing: Switch(
                    value: isIndo,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      // Logika ganti bahasa
                      if (value) {
                        ref.read(localeProvider.notifier).state = const Locale('id', 'ID');
                      } else {
                        ref.read(localeProvider.notifier).state = const Locale('en', 'US');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- [TAMBAHAN] TOMBOL TEST NOTIFIKASI ---
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final notifService = ref.read(notificationServiceProvider);
                  
                  // 1. Minta Izin Dulu (PENTING untuk Android 13+)
                  await notifService.requestPermissions();

                  // 2. Panggil fungsi test notifikasi
                  await notifService.showInstantNotification();
                  
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isIndo 
                          ? 'Perintah notifikasi dikirim! Cek status bar.' 
                          : 'Notification sent! Check status bar.',
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: Text(isIndo ? 'Coba Test Notifikasi' : 'Test Notification'),
              // ... style tombol tetap sama ...
            ),
          ),
          // -----------------------------------------

          const SizedBox(height: 20),
          Center(
            child: Text(
              isIndo
                  ? 'Geser tombol di atas untuk ganti ke Bahasa Inggris'
                  : 'Toggle the switch above to change to Indonesian',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}