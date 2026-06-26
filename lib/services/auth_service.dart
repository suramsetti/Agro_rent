import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  FirebaseAuth? _auth;
  String? _verificationId;

  FirebaseAuth get auth {
    if (_auth != null) return _auth!;
    try {
      _auth = FirebaseAuth.instance;
      return _auth!;
    } catch (e) {
      throw StateError('Firebase is not initialized. Please configure Firebase for web.');
    }
  }

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  User? get currentUser => auth.currentUser;
  String? get currentUserEmail => auth.currentUser?.email;
  String? get currentUserPhone => auth.currentUser?.phoneNumber;

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    if (!isFirebaseAvailable) {
      onError(FirebaseAuthException(
        code: 'unavailable',
        message: 'Firebase is not configured for this platform.',
      ));
      return;
    }

    try {
      // Format phone number if needed
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Default to India country code
      }

      await auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          try {
            await auth.signInWithCredential(credential);
            onCodeSent(_verificationId ?? '');
          } catch (e) {
            onError(FirebaseAuthException(
              code: 'verification-failed',
              message: 'Auto-verification failed: $e',
            ));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = _getPhoneErrorMessage(e);
          onError(FirebaseAuthException(
            code: e.code,
            message: errorMessage,
          ));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getPhoneErrorMessage(e);
      onError(FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      ));
    } catch (e) {
      onError(FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      ));
    }
  }

  Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
    required void Function() onSuccess,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    if (!isFirebaseAvailable) {
      onError(FirebaseAuthException(
        code: 'unavailable',
        message: 'Firebase is not configured for this platform.',
      ));
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      
      await auth.signInWithCredential(credential);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getPhoneErrorMessage(e);
      onError(FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      ));
    } catch (e) {
      onError(FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      ));
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required void Function() onSuccess,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    if (!isFirebaseAvailable) {
      onError(FirebaseAuthException(
        code: 'unavailable',
        message: 'Firebase is not configured for this platform.',
      ));
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      onError(FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      ));
    } catch (e) {
      onError(FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      ));
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required void Function() onSuccess,
    required void Function(FirebaseAuthException e) onError,
  }) async {
    if (!isFirebaseAvailable) {
      onError(FirebaseAuthException(
        code: 'unavailable',
        message: 'Firebase is not configured for this platform.',
      ));
      return;
    }

    try {
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getErrorMessage(e);
      onError(FirebaseAuthException(
        code: e.code,
        message: errorMessage,
      ));
    } catch (e) {
      onError(FirebaseAuthException(
        code: 'unknown',
        message: 'An unexpected error occurred: $e',
      ));
    }
  }

  Future<void> signOut() async {
    if (isFirebaseAvailable) {
      await auth.signOut();
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Please sign in instead.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  String _getPhoneErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is not valid. Please check and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'session-expired':
        return 'The SMS code has expired. Please request a new one.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Phone authentication failed. Please try again.';
    }
  }
}

