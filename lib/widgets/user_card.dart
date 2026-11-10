import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/nguoi_dung.dart';

class UserCard extends StatelessWidget {
  final NguoiDung nguoiDung;
  final VoidCallback onSua;
  final VoidCallback onXoa;

  const UserCard({
    super.key,
    required this.nguoiDung,
    required this.onSua,
    required this.onXoa,
  });

  static const Color _mauChinh = Color(0xFF1A237E);

  // Bảng màu cho avatar chữ cái (khi người dùng chưa có ảnh)
  static const List<Color> _bangMau = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF6C00),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFFEC407A),
  ];

  // Chuyển chuỗi Base64 → ImageProvider để hiển thị
  ImageProvider? _layAnhProvider() {
    if (nguoiDung.hinhanh.isEmpty) return null;
    try {
      final base64Str = nguoiDung.hinhanh.contains(',')
          ? nguoiDung.hinhanh.split(',').last
          : nguoiDung.hinhanh;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }

  // Lấy chữ cái đầu của từ cuối trong họ tên (vd: "Lê Thị Phát" → "P")
  String _chuCaiDau() {
    final ten = nguoiDung.hoten.trim();
    if (ten.isEmpty) return '?';
    return ten.split(RegExp(r'\s+')).last[0].toUpperCase();
  }

  Color _mauAvatar() {
    final ma = nguoiDung.hoten.codeUnits.fold<int>(0, (a, b) => a + b);
    return _bangMau[ma % _bangMau.length];
  }

  Widget _buildAvatar(ImageProvider? imageProvider) {
    final mau = _mauAvatar();
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: mau.withOpacity(0.35), width: 2),
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: mau,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Text(
                _chuCaiDau(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _layAnhProvider();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAF6)),
        boxShadow: [
          BoxShadow(
            color: _mauChinh.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSua, // chạm vào thẻ để sửa
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // ── Ảnh đại diện ──
                _buildAvatar(imageProvider),
                const SizedBox(width: 14),

                // ── Thông tin ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nguoiDung.hoten,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1B1F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 15, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              nguoiDung.email,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Nút Sửa / Xóa ──
                const SizedBox(width: 8),
                _NutHanhDong(
                  tooltip: 'Sửa',
                  icon: Icons.edit_outlined,
                  mau: _mauChinh,
                  onTap: onSua,
                ),
                const SizedBox(width: 8),
                _NutHanhDong(
                  tooltip: 'Xóa',
                  icon: Icons.delete_outline,
                  mau: const Color(0xFFD32F2F),
                  onTap: onXoa,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Nút nhỏ có nền nhạt, dùng cho Sửa / Xóa
class _NutHanhDong extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color mau;
  final VoidCallback onTap;

  const _NutHanhDong({
    required this.tooltip,
    required this.icon,
    required this.mau,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: mau.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 20, color: mau),
          ),
        ),
      ),
    );
  }
}