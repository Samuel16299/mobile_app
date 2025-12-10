import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final baseTheme = Theme.of(context);

    final montTheme = baseTheme.copyWith(
      textTheme: GoogleFonts.montserratTextTheme(baseTheme.textTheme),
    );

    final currentLocale = ref.watch(localeProvider);
    final isIndo = currentLocale.languageCode == 'id';

    final labels = {
      'welcome': isIndo ? 'Halo, Selamat datang!' : 'Hello, Welcome!',
      'subtitle': isIndo
          ? 'Masuk untuk mengelola tagihanmu'
          : 'Sign in to manage your bills',
      'email_hint': 'contoh@email.com',
      'label_email': 'Email',
      'label_password': 'Password',
      'btn_signin': isIndo ? 'Masuk' : 'Sign In',
      'btn_register': isIndo ? 'Daftar' : 'Register',
      'forgot_pass': isIndo ? 'Lupa kata sandi?' : 'Forgot password?',
      'valid_email_req': isIndo ? 'Email wajib diisi' : 'Email is required',
      'valid_email_fmt': isIndo ? 'Masukkan email valid' : 'Enter valid email',
      'valid_pass_len': isIndo ? 'Minimal 6 karakter' : 'Min 6 chars',
      'forgot_msg': isIndo ? 'Fitur belum tersedia' : 'Feature not available',
    };

    return Theme(
      data: montTheme,
      child: Scaffold(
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labels['welcome']!,
                        textAlign: TextAlign.center,
                        style: montTheme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
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
                                  labelText: labels['label_email'],
                                  hintText: labels['email_hint'],
                                  prefixIcon:
                                  const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  labelStyle: montTheme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (v) => _email = v,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return labels['valid_email_req'];
                                  }
                                  if (!v.contains('@')) {
                                    return labels['valid_email_fmt'];
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                key: const Key('passwordField'),
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: labels['label_password'],
                                  prefixIcon:
                                  const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setState(
                                            () => _obscure = !_obscure),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  labelStyle: montTheme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (v) => _password = v,
                                validator: (v) => (v != null && v.length >= 6)
                                    ? null
                                    : labels['valid_pass_len'],
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
                                          Colors.blue.shade600,
                                          Colors.blue.shade400,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: _loading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        labels['btn_signin']!,
                                        style: montTheme.textTheme
                                            .labelLarge
                                            ?.copyWith(
                                            color: Colors.white,
                                            fontWeight:
                                            FontWeight.bold),
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
                                        builder: (_) =>
                                        const RegisterScreen()),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    labels['btn_register']!,
                                    style: montTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              labels['forgot_msg']!)),
                                    );
                                  },
                                  child: Text(
                                    labels['forgot_pass']!,
                                    style: montTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        labels['subtitle']!,
                        style: montTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
