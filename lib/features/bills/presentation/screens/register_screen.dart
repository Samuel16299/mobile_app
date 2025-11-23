import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../settings/providers/locale_provider.dart'; // Import provider bahasa

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    
    final isIndo = ref.read(localeProvider).languageCode == 'id';
    final successMsg = isIndo ? 'Registrasi berhasil' : 'Registration successful';

    try {
      final auth = ref.read(authServiceProvider);
      await auth.registerWithEmail(_email.trim(), _password.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMsg)));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. AMBIL BAHASA
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    // 2. KAMUS KATA (Register)
    final labels = {
      'title': isIndo ? 'Daftar Akun' : 'Register Account',
      'label_email': 'Email',
      'label_password': 'Password',
      'btn_submit': isIndo ? 'Daftar Sekarang' : 'Sign Up Now',
      'valid_email': isIndo ? 'Email tidak valid' : 'Invalid email',
      'valid_pass': isIndo ? 'Minimal 6 karakter' : 'Min 6 chars',
    };

    return Scaffold(
      appBar: AppBar(title: Text(labels['title']!)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: labels['label_email']),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => _email = v,
                    validator: (v) => v != null && v.contains('@') ? null : labels['valid_email'],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(labelText: labels['label_password']),
                    obscureText: true,
                    onChanged: (v) => _password = v,
                    validator: (v) => v != null && v.length >= 6 ? null : labels['valid_pass'],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : Text(labels['btn_submit']!),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}