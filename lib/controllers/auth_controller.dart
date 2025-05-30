import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cadastro de novo usuário
  Future<String?> register(
    String email,
    String password,
    String userType,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Salvar o tipo de usuário no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'userType': userType,
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Login de usuário existente
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Pegar o tipo do usuário
  Future<String?> getUserType() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      return snapshot['userType'];
    }
    return null;
  }
}
