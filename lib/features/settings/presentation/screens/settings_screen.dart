import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

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
