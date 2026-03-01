import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _db = FirestoreService();

  // Stream of auth state changes (used by AuthGate)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Expose current user
  User? get currentUser => _auth.currentUser;

  /// Initiate Phone OTP Flow (+91 prefixed)
  Future<void> sendOtp({
    required String phone,
    required String name,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException e) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    // Add prefix for Indian numbers
    final String phoneE164 = phone.startsWith('+91') ? phone : '+91$phone';

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verify triggered
        onAutoVerified(credential);

        // After auto-verification, ensure profile exists
        UserCredential userCred = await _auth.signInWithCredential(credential);
        if (userCred.user != null) {
          await _db.upsertUserProfile(
            uid: userCred.user!.uid,
            name: name,
            phone: phoneE164,
          );
        }
      },
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Manually verify OTP code entered by the user
  Future<bool> verifyOtpAndLogin(
    String verificationId,
    String smsCode,
    String name,
    String phone,
  ) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);

      if (userCred.user != null) {
        final String phoneE164 = phone.startsWith('+91') ? phone : '+91$phone';
        await _db.upsertUserProfile(
          uid: userCred.user!.uid,
          name: name,
          phone: phoneE164,
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  /// Sign in with Google Account
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false; // Canceled by user

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCred = await _auth.signInWithCredential(credential);

      if (userCred.user != null) {
        // Upsert standard profile, leaving phone empty for now
        await _db.upsertUserProfile(
          uid: userCred.user!.uid,
          name: userCred.user!.displayName ?? 'User',
          phone: '', // Needs to be gathered if strict requirement
        );
        return true;
      }
      return false;
    } catch (e) {
      print("Error with Google Sign-in: $e");
      return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
