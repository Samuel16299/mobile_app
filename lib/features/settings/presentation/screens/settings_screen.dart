import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../bills/providers/bills_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Title
          Text(
            'Umum',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // --- TOMBOL TEST NOTIFIKASI ---
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: Colors.orange),
                title: const Text('Test Notifikasi'),
                subtitle: const Text('Coba kirim notifikasi manual'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  try {
                    // Pastikan provider ini ada di bills_provider.dart
                    final notifService = ref.read(notificationServiceProvider);
                    
                    // 1. Minta Izin
                    await notifService.requestPermissions();

                    // 2. Panggil fungsi test
                    await notifService.showInstantNotification();
                    
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Perintah notifikasi dikirim! Cek status bar.'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
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
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Versi Aplikasi 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}