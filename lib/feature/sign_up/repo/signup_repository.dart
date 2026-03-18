import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unilib/feature/home/data/models/user_model.dart';

class SignupRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String faculty,
    required String academicYear,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'studentId': studentId,
        'faculty': faculty,
        'academicYear': academicYear,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _db.collection('users').doc(cred.user!.uid).set(userData);

      return UserModel.fromMap(userData, cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw mapError(e);
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  String mapError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'network-request-failed':
          return 'No internet connection.';
        case 'operation-not-allowed':
          return 'Email sign-up is not enabled.';
        default:
          return 'Auth error: ${e.message}';
      }
    }
    if (e is FirebaseException) {
      return 'Database error: ${e.message}';
    }
    return 'Something went wrong: $e';
  }
}
