// ============================================================
// Service: DatabaseService
// CRUD người dùng trên Firebase Realtime Database
// Node: "nguoidung" - chỉ 4 trường: email, matkhau, hoten, hinhanh
// ============================================================

import 'package:firebase_database/firebase_database.dart';
import '../models/nguoi_dung.dart';

class DatabaseService {
  // Tham chiếu đến node "nguoidung" trong Realtime Database
  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref().child('nguoidung');

  // ─── Lấy danh sách tất cả người dùng (realtime stream) ───
  Stream<List<NguoiDung>> layDanhSach() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final map = Map<dynamic, dynamic>.from(data as Map);
      return map.entries
          .map((e) => NguoiDung.fromMap(
                Map<dynamic, dynamic>.from(e.value as Map),
                e.key.toString(),
              ))
          .toList();
    });
  }

  // ─── Thêm người dùng mới ───
  // Realtime Database tự sinh key → dùng làm id
  Future<void> themNguoiDung(NguoiDung nd) async {
    await _ref.push().set(nd.toMap());
  }

  // ─── Cập nhật người dùng theo id ───
  Future<void> suaNguoiDung(NguoiDung nd) async {
    await _ref.child(nd.id).update(nd.toMap());
  }

  // ─── Xóa người dùng theo id ───
  Future<void> xoaNguoiDung(String id) async {
    await _ref.child(id).remove();
  }
}
