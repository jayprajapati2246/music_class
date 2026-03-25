import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> fetchServices() async {
    if (_uid == null) return null;
    DocumentSnapshot doc = await _firestore.collection('users').doc(_uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['services'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> updateServices(Map<String, dynamic> services) async {
    if (_uid == null) return;
    await _firestore.collection('users').doc(_uid).set({
      'services': services,
    }, SetOptions(merge: true));
  }

  Future<void> clearServices() async {
    if (_uid == null) return;
    await _firestore.collection('users').doc(_uid).set({
      'services': {
        'courses': [],
        'batchTimes': [],
      },
    }, SetOptions(merge: true));
  }
}
