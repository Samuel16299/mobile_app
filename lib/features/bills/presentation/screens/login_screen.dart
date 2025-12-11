import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tema global yang sudah menggunakan Montserrat
    final theme = Theme.of(context);

    // Text styles khusus untuk layar ini supaya kontras lebih baik
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: 28,
      shadows: const [
        Shadow(
          color: Colors.black45,
          offset: Offset(0, 2),
          blurRadius: 6,
        ),
      ],
    );

    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white70,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      shadows: const [
        Shadow(
          color: Colors.black38,
          offset: Offset(0, 1),
          blurRadius: 4,
        ),
      ],
    );

    final cardLabelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade800,
      fontWeight: FontWeight.w700,
    );

    final buttonTextStyle = theme.textTheme.labelLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
    );

    final outlinedButtonTextStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: Colors.black87,
    );

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
              color: Colors.black.withOpacity(0.18),
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
                      'Halo, Selamat datang!',
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              key: const Key('emailField'),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'contoh@email.com',
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                labelStyle: cardLabelStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) => _email = v,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email wajib diisi';
                                }
                                if (!v.contains('@')) {
                                  return 'Masukkan email valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const Key('passwordField'),
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                labelStyle: cardLabelStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) => _password = v,
                              validator: (v) => (v != null && v.length >= 6)
                                  ? null
                                  : 'Minimal 6 karakter',
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  elevation: 4,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade700,
                                        Colors.blue.shade500,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Text(
                                      'Masuk',
                                      style: buttonTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const RegisterScreen()),
                                ),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  'Daftar',
                                  style: outlinedButtonTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // "Lupa kata sandi?" telah dihapus sesuai permintaan
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Masuk untuk mengelola tagihanmu',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
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
