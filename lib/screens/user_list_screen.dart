// ============================================================
// Screen: UserListScreen
// Danh sách người dùng từ Realtime Database
// Chức năng: Tìm kiếm, Thêm/Sửa/Xóa, Đăng xuất
// ============================================================

import 'package:flutter/material.dart';
import '../models/nguoi_dung.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'user_form_screen.dart';
import '../widgets/user_card.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  static const Color _mauChinh = Color(0xFF1A237E);
  static const Color _mauNen = Color(0xFFF5F6FB);

  final _db = DatabaseService();
  final _auth = AuthService();
  final _searchCtrl = TextEditingController();
  String _tuKhoa = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Lọc danh sách theo từ khóa ───
  List<NguoiDung> _loc(List<NguoiDung> tatCa) {
    if (_tuKhoa.isEmpty) return tatCa;
    return tatCa
        .where((nd) =>
            nd.hoten.toLowerCase().contains(_tuKhoa.toLowerCase()) ||
            nd.email.toLowerCase().contains(_tuKhoa.toLowerCase()))
        .toList();
  }

  // ─── SnackBar dùng chung ───
  void _thongBao(String noiDung, {bool loi = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(noiDung),
        backgroundColor: loi ? const Color(0xFFD32F2F) : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Hộp thoại xác nhận dùng chung ───
  Future<bool?> _hopThoaiXacNhan({
    required String tieuDe,
    required String noiDung,
    required String nhanXacNhan,
    required IconData icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFD32F2F)),
        ),
        title: Text(tieuDe,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(noiDung, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(100, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              minimumSize: const Size(100, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(nhanXacNhan),
          ),
        ],
      ),
    );
  }

  // ─── Xác nhận xóa ───
  Future<void> _xacNhanXoa(NguoiDung nd) async {
    final dongY = await _hopThoaiXacNhan(
      tieuDe: 'Xác nhận xóa',
      noiDung: 'Xóa người dùng\n"${nd.hoten}"?',
      nhanXacNhan: 'Xóa',
      icon: Icons.delete_outline,
    );
    if (dongY == true && mounted) {
      try {
        await _db.xoaNguoiDung(nd.id);
        _thongBao('Đã xóa người dùng!');
      } catch (e) {
        _thongBao('Lỗi: $e', loi: true);
      }
    }
  }

  // ─── Đăng xuất ───
  Future<void> _dangXuat() async {
    final dongY = await _hopThoaiXacNhan(
      tieuDe: 'Đăng xuất',
      noiDung: 'Bạn có muốn đăng xuất?',
      nhanXacNhan: 'Đăng xuất',
      icon: Icons.logout,
    );
    if (dongY == true) {
      await _auth.dangXuat();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  // ─── Mở form Thêm/Sửa ───
   void _moForm({NguoiDung? nd}) {
    showDialog(
      context: context,
      barrierDismissible: false, // bấm ra ngoài không đóng, tránh mất dữ liệu đang nhập
      builder: (_) => UserFormScreen(nguoiDungSua: nd),
    );
  }

  // ─── Thanh tìm kiếm ───
  Widget _buildThanhTimKiem() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _mauChinh.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Tìm theo họ tên hoặc email...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.search, color: _mauChinh),
            suffixIcon: _tuKhoa.isNotEmpty
                ? IconButton(
                    tooltip: 'Xóa từ khóa',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _tuKhoa = '');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE8EAF6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _mauChinh, width: 1.5),
            ),
          ),
          onChanged: (v) => setState(() => _tuKhoa = v),
        ),
      ),
    );
  }

  // ─── Số kết quả ───
  Widget _buildSoKetQua(int hienThi, int tatCa) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Icon(Icons.people_outline, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            'Hiển thị $hienThi/$tatCa người dùng',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trạng thái trống ───
  Widget _buildTrong({required bool dangTimKiem}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _mauChinh.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                dangTimKiem ? Icons.search_off : Icons.group_add_outlined,
                size: 44,
                color: _mauChinh,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              dangTimKiem
                  ? 'Không tìm thấy người dùng nào'
                  : 'Chưa có người dùng nào',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              dangTimKiem
                  ? 'Thử tìm bằng họ tên hoặc email khác.'
                  : 'Nhấn "Thêm" để tạo người dùng đầu tiên.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mauNen,
      appBar: AppBar(
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: _dangXuat,
          ),
          const SizedBox(width: 4),
        ],
      ),

      // FAB: Thêm người dùng
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _moForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _mauChinh,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Giới hạn chiều rộng + căn giữa (đẹp hơn trên web)
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: StreamBuilder<List<NguoiDung>>(
            stream: _db.layDanhSach(),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Lỗi: ${snap.error}'));
              }

              final tatCa = snap.data ?? [];
              final hienThi = _loc(tatCa);

              return Column(
                children: [
                  _buildThanhTimKiem(),
                  _buildSoKetQua(hienThi.length, tatCa.length),

                  // ── Danh sách ──
                  Expanded(
                    child: hienThi.isEmpty
                        ? _buildTrong(dangTimKiem: _tuKhoa.isNotEmpty)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                            itemCount: hienThi.length,
                            itemBuilder: (ctx, i) {
                              final nd = hienThi[i];
                              return UserCard(
                                nguoiDung: nd,
                                onSua: () => _moForm(nd: nd),
                                onXoa: () => _xacNhanXoa(nd),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}