// ============================================================
// Screen: UserFormScreen
// Hộp thoại Thêm mới hoặc Sửa người dùng
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/nguoi_dung.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class UserFormScreen extends StatefulWidget {
  final NguoiDung? nguoiDungSua;
  const UserFormScreen({super.key, this.nguoiDungSua});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  static const Color _mauChinh = Color(0xFF1A237E);

  final _formKey = GlobalKey<FormState>();
  final _hotenCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _db = DatabaseService();
  final _storage = StorageService();

  XFile? _anhMoi;
  Uint8List? _anhBytes; // Bytes để preview ảnh mới
  String _anhCu = ''; // Base64 ảnh cũ (khi sửa)
  bool _dangLuu = false;
  bool _hienMatKhau = false;
  String? _loi; // Thông báo lỗi hiện trong hộp thoại

  bool get _laSua => widget.nguoiDungSua != null;

  @override
  void initState() {
    super.initState();
    if (_laSua) {
      final nd = widget.nguoiDungSua!;
      _hotenCtrl.text = nd.hoten;
      _emailCtrl.text = nd.email;
      _passCtrl.text = nd.matkhau;
      _anhCu = nd.hinhanh;
    }
  }

  @override
  void dispose() {
    _hotenCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─── Chọn ảnh ───
  Future<void> _chonAnh() async {
    final file = await _storage.chonAnh();
    if (file != null) {
      final bytes = await file.readAsBytes();
      setState(() {
        _anhMoi = file;
        _anhBytes = bytes;
        _loi = null;
      });
    }
  }

  // ─── Lấy ImageProvider từ bytes hoặc base64 cũ ───
  ImageProvider? _layImageProvider() {
    if (_anhBytes != null) return MemoryImage(_anhBytes!);
    if (_anhCu.isNotEmpty) {
      try {
        final b64 = _anhCu.contains(',') ? _anhCu.split(',').last : _anhCu;
        return MemoryImage(base64Decode(b64));
      } catch (_) {}
    }
    return null;
  }

  // ─── Avatar tròn + nút camera ───
  Widget _buildAvatar() {
    final imageProvider = _layImageProvider();
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: _mauChinh.withOpacity(0.1),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 42, color: _mauChinh)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _dangLuu ? null : _chonAnh,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _mauChinh,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Kiểu ô nhập dùng chung ───
  InputDecoration _kieuO({
    required String nhan,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: nhan,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _mauChinh, width: 1.5),
      ),
    );
  }

  // ─── Lưu ───
  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;

    if (_anhMoi == null && _anhCu.isEmpty) {
      setState(() => _loi = 'Vui lòng chọn ảnh đại diện.');
      return;
    }

    setState(() {
      _dangLuu = true;
      _loi = null;
    });

    try {
      String hinhBase64 = _anhCu;
      if (_anhMoi != null) {
        hinhBase64 = await _storage.anhThanhBase64(_anhMoi!);
      }

      final nd = NguoiDung(
        id: _laSua ? widget.nguoiDungSua!.id : '',
        email: _emailCtrl.text.trim(),
        matkhau: _passCtrl.text.trim(),
        hoten: _hotenCtrl.text.trim(),
        hinhanh: hinhBase64,
      );

      if (_laSua) {
        await _db.suaNguoiDung(nd);
      } else {
        await _db.themNguoiDung(nd);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_laSua
                ? 'Cập nhật thành công!'
                : 'Thêm người dùng thành công!'),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _loi = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tiêu đề ──
                Text(
                  _laSua ? 'Sửa người dùng' : 'Thêm người dùng',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),

                // ── Avatar + hướng dẫn ──
                _buildAvatar(),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Nhấn vào camera để chọn ảnh',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Họ tên ──
                TextFormField(
                  controller: _hotenCtrl,
                  decoration: _kieuO(
                      nhan: 'Họ tên *', icon: Icons.person_outline),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập họ tên.';
                    }
                    if (v.trim().length < 2) return 'Họ tên ít nhất 2 ký tự.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Email ──
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      _kieuO(nhan: 'Email *', icon: Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập email.';
                    }
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Email không đúng định dạng.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // ── Mật khẩu ──
                TextFormField(
                  controller: _passCtrl,
                  obscureText: !_hienMatKhau,
                  decoration: _kieuO(
                    nhan: 'Mật khẩu *',
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_hienMatKhau
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _hienMatKhau = !_hienMatKhau),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Vui lòng nhập mật khẩu.';
                    }
                    if (v.length < 6) return 'Mật khẩu ít nhất 6 ký tự.';
                    return null;
                  },
                ),

                // ── Thông báo lỗi (nếu có) ──
                if (_loi != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _loi!,
                      style: const TextStyle(
                          color: Color(0xFFD32F2F), fontSize: 13),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // ── Nút Hủy / Lưu ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _dangLuu ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        minimumSize: const Size(80, 44),
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _dangLuu ? null : _luu,
                      icon: _dangLuu
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save, size: 18),
                      label: Text(
                        _dangLuu ? 'Đang lưu...' : (_laSua ? 'Cập nhật' : 'Lưu'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _mauChinh,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(110, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}