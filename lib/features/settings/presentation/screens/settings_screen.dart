import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bills/providers/bills_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDailyReminderEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (!mounted) return;

      setState(() {
        _isDailyReminderEnabled = prefs.getBool('daily_reminder') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// Simpan status switch & atur notifikasi
  Future<void> _toggleDailyReminder(bool value) async {
    setState(() {
      _isDailyReminderEnabled = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('daily_reminder', value);

      final notifService = ref.read(notificationServiceProvider);

      if (value) {
        // Aktifkan
        await notifService.requestPermissions();
        await notifService.scheduleDailyNotification();
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pengingat harian aktif (09:00)'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await notifService.cancelNotification(999);
        
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengingat harian dimatikan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDailyReminderEnabled = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Card(
                  elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.alarm, color: Colors.blue.shade700),
                        ),
                        title: const Text(
                          'Ingatkan Tagihan Tiap Hari',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        value: _isDailyReminderEnabled,
                        activeColor: Colors.blue,
                        onChanged: (val) {
                          _toggleDailyReminder(val);
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Tentang',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                
                Card(
                   elevation: 0,
                  color: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Versi Aplikasi'),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}