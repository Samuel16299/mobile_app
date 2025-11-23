import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../../settings/providers/locale_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _loading = false;
  bool _obscure = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      await auth.loginWithEmail(_email.trim(), _password.trim());
      if (!mounted) return;
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 1. AMBIL STATUS BAHASA
    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    // 2. KAMUS KATA (Login)
    final labels = {
      'welcome': isIndo ? 'Halo, Selamat datang!' : 'Hello, Welcome!',
      'subtitle': isIndo ? 'Masuk untuk mengelola tagihanmu' : 'Sign in to manage your bills',
      'email_hint': 'contoh@email.com', // Universal
      'label_email': 'Email',
      'label_password': 'Password', // Universal
      'btn_signin': isIndo ? 'Masuk' : 'Sign In',
      'btn_register': isIndo ? 'Daftar' : 'Register',
      'forgot_pass': isIndo ? 'Lupa kata sandi?' : 'Forgot password?',
      'valid_email_req': isIndo ? 'Email wajib diisi' : 'Email is required',
      'valid_email_fmt': isIndo ? 'Masukkan email valid' : 'Enter valid email',
      'valid_pass_len': isIndo ? 'Minimal 6 karakter' : 'Min 6 chars',
      'forgot_msg': isIndo ? 'Fitur belum tersedia' : 'Feature not available',
    };

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_login.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.18 * 255).round()),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels['welcome']!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(242),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(36),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key('emailField'),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: labels['label_email'],
                                hintText: labels['email_hint'],
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) => _email = v,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return labels['valid_email_req'];
                                if (!v.contains('@')) return labels['valid_email_fmt'];
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const Key('passwordField'),
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: labels['label_password'],
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) => _password = v,
                              validator: (v) => (v != null && v.length >= 6) ? null : labels['valid_pass_len'],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : Text(labels['btn_signin']!, style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(labels['btn_register']!, style: theme.textTheme.labelLarge),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(labels['forgot_msg']!)));
                                },
                                child: Text(labels['forgot_pass']!, style: TextStyle(color: Colors.grey.shade700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      labels['subtitle']!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}