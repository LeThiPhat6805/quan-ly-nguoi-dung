// ============================================================
// Screen: LoginScreen
// Màn hình đăng nhập bằng email/mật khẩu qua Firebase Auth
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'user_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _auth       = AuthService();

  bool _dangTai     = false;
  bool _hienMatKhau = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _dangTai = true);

    try {
      await _auth.dangNhap(
        email:    _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          msg = 'Email hoặc mật khẩu không đúng.';
          break;
        case 'wrong-password':
          msg = 'Mật khẩu không đúng.';
          break;
        case 'invalid-email':
          msg = 'Email không hợp lệ.';
          break;
        case 'too-many-requests':
          msg = 'Thử lại quá nhiều lần. Vui lòng đợi.';
          break;
        default:
          msg = 'Lỗi [${e.code}]: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _dangTai = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // ── Icon + Tiêu đề ──
                    const Icon(Icons.manage_accounts,
                        size: 72, color: Color(0xFF1A237E)),
                    const SizedBox(height: 8),
                    const Text(
                      'QUẢN LÝ NGƯỜI DÙNG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Text('Phân hệ Admin',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 28),

                    // ── Email ──
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập email.';
                        }
                        if (!v.contains('@')) return 'Email không hợp lệ.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Mật khẩu ──
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: !_hienMatKhau,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_hienMatKhau
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _hienMatKhau = !_hienMatKhau),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Vui lòng nhập mật khẩu.';
                        }
                        if (v.length < 6) {
                          return 'Mật khẩu ít nhất 6 ký tự.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ── Nút Đăng nhập ──
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _dangTai ? null : _dangNhap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _dangTai
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('ĐĂNG NHẬP',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ), // đóng Card
          ), // đóng ConstrainedBox
        ), // đóng SingleChildScrollView
      ), // đóng Center
    );
  }
}
