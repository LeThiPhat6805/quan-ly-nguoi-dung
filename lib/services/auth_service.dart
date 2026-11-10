// ============================================================
// Service: AuthService
// Xử lý đăng nhập / đăng xuất bằng Firebase Authentication
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;

  // Stream theo dõi trạng thái đăng nhập (realtime)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Đăng nhập bằng email và mật khẩu
  Future<UserCredential> dangNhap({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // Đăng xuất
  Future<void> dangXuat() async {
    await _auth.signOut();
  }
}
