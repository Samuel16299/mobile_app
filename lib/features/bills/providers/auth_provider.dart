import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/service/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream of Firebase User (null when signed out)
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges();
});
