import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential> signUp(
      {required String email,
      required String password,
      required String name,
      required String hospital}) async {
    try {
      // auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'name': name,
        'hospital': hospital,
        'role': 'Doctor',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return result;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In
  Future<UserCredential> signIn(
      {required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
