import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository(this._auth);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng ký Firebase: ${e.message}");
      return null;
    } catch (e) {
      print("Lỗi không xác định: $e");
      return null;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Lỗi đăng nhập Firebase: ${e.message}");
      return null;
    } catch (e) {
      print("Lỗi không xác định: $e");
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}