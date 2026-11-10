// ============================================================
// Model: NguoiDung
// Ánh xạ dữ liệu từ Firebase Realtime Database node "nguoidung"
// Chỉ có đúng 4 trường theo yêu cầu đề bài
// ============================================================

class NguoiDung {
  final String id;       // Key tự sinh của Realtime Database (không phải field)
  final String email;    // Email người dùng
  final String matkhau;  // Mật khẩu (lưu trực tiếp theo yêu cầu đề)
  final String hoten;    // Họ tên đầy đủ
  final String hinhanh;  // URL ảnh đại diện trên Firebase Storage

  NguoiDung({
    required this.id,
    required this.email,
    required this.matkhau,
    required this.hoten,
    required this.hinhanh,
  });

  // Chuyển từ Realtime Database snapshot → NguoiDung object
  factory NguoiDung.fromMap(Map<dynamic, dynamic> map, String key) {
    return NguoiDung(
      id:       key,
      email:    map['email']    ?? '',
      matkhau:  map['matkhau']  ?? '',
      hoten:    map['hoten']    ?? '',
      hinhanh:  map['hinhanh']  ?? '',
    );
  }

  // Chuyển từ NguoiDung object → Map để lưu Realtime Database
  // Chỉ 4 trường: email, matkhau, hoten, hinhanh
  Map<String, dynamic> toMap() {
    return {
      'email':   email,
      'matkhau': matkhau,
      'hoten':   hoten,
      'hinhanh': hinhanh,
    };
  }
}
