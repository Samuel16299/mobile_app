import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk menyimpan status bahasa yang dipilih
// Default kita set ke Indonesia ('id')
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('id', 'ID'); 
});