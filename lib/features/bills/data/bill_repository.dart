import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';

class BillRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> billsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('bills');

  Stream<List<Bill>> streamBills(String uid) {
    return billsRef(uid)
        .orderBy('dueDate')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Bill.fromDoc(d)).toList());
  }

  Future<void> createBill(Bill bill) async {
    final ref = billsRef(bill.userId);
    await ref.add(bill.toMap());
  }

  Future<void> updateBill(Bill bill) async {
    final ref = billsRef(bill.userId);
    await ref.doc(bill.id).update(bill.toMap());
  }

  Future<void> updateBillStatus(String uid, String billId, bool isPaid) async {
    final ref = billsRef(uid);
    await ref.doc(billId).update({'isPaid': isPaid});
  }

  Future<void> deleteBill(String uid, String billId) async {
    final ref = billsRef(uid);
    await ref.doc(billId).delete();
  }
}
