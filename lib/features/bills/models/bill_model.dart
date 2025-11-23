import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String category;
  final String? notes;
  final String repeat; // e.g. 'none', 'monthly', 'yearly'
  final String userId;
  final Timestamp createdAt;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.notes,
    required this.repeat,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'category': category,
      'notes': notes,
      'repeat': repeat,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  factory Bill.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Bill(
      id: doc.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] is int) ? (data['amount'] as int).toDouble() : (data['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      category: data['category'] as String? ?? '',
      notes: data['notes'] as String?,
      repeat: data['repeat'] as String? ?? 'none',
      userId: data['userId'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
