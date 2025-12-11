import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = ref.read(authServiceProvider);
      await auth.registerWithEmail(_email.trim(), _password.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),

                    Text('Daftar Akun', style: titleStyle),
                    const SizedBox(height: 6),
                    Text(
                      'Buat akun untuk mulai mengelola tagihan',
                      textAlign: TextAlign.center,
                      style: subtitleStyle,
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
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
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
                              validator: (v) => v != null && v.contains('@')
                                  ? null
                                  : 'Email tidak valid',
                            ),

                            const SizedBox(height: 12),

                            TextFormField(
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
                              validator: (v) => v != null && v.length >= 6
                                  ? null
                                  : 'Minimal 6 karakter',
                            ),

                            const SizedBox(height: 18),

                            // =======================
                            //      TOMBOL DAFTAR
                            // =======================
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _register,
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
                                      'Daftar Sekarang',
                                      style: buttonTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =======================
                            //       TOMBOL KEMBALI
                            // =======================
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.blue.shade200),
                                  backgroundColor: Colors.blue.shade50,
                                ),
                                child: Text(
                                  'Kembali',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
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
