import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserServicesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> fetchServices() async {
    if (_uid == null) return null;
    
    // Fetch from subcollection
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('services')
        .get();

    if (snapshot.docs.isEmpty) {
      // Fallback to check old field for backward compatibility
      DocumentSnapshot doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['services'] as Map<String, dynamic>?;
      }
      return null;
    }

    Map<String, dynamic> services = {
      'courses': [],
      'batchTimes': [],
      'fees': [],
    };

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('course')) services['courses'].add(data['course']);
      if (data.containsKey('batch')) services['batchTimes'].add(data['batch']);
      if (data.containsKey('fee')) services['fees'].add(data['fee'].toString());
    }

    return services;
  }

  Future<void> updateServices(Map<String, dynamic> services) async {
    if (_uid == null) return;
    
    // This method seems to be used for bulk update. 
    // In subcollection structure, we should handle items individually or clear and re-add.
    // For now, let's implement a replacement logic to maintain compatibility.
    
    // 1. Clear existing subcollection
    var existing = await _firestore.collection('users').doc(_uid).collection('services').get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    // 2. Add new items
    List<String> courses = List<String>.from(services['courses'] ?? []);
    List<String> batches = List<String>.from(services['batchTimes'] ?? []);

    for (var c in courses) {
      await _firestore.collection('users').doc(_uid).collection('services').add({
        'course': c,
        'status': 'Active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    for (var b in batches) {
      await _firestore.collection('users').doc(_uid).collection('services').add({
        'batch': b,
        'status': 'Active',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    
    // 3. Ensure old field is removed
    await _firestore.collection('users').doc(_uid).update({
      'services': FieldValue.delete(),
    });
  }

  Future<void> clearServices() async {
    if (_uid == null) return;
    
    var existing = await _firestore.collection('users').doc(_uid).collection('services').get();
    for (var doc in existing.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('users').doc(_uid).update({
      'services': FieldValue.delete(),
    });
  }
}
