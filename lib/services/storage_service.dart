// ============================================================
// Service: StorageService
// Chuyển ảnh thành Base64 để lưu vào Realtime Database
// Dùng package 'image' để nén + resize → hoạt động cả Web và Android
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // ─── Chọn ảnh từ thư viện thiết bị (Web + Android) ───
  Future<XFile?> chonAnh() async {
    return await _picker.pickImage(source: ImageSource.gallery);
  }

  // ─── Chuyển XFile thành Base64 đã nén ───
  // Resize về tối đa 300x300 px + nén quality 60% → ~10-30KB
  // Phù hợp để lưu vào Firebase Realtime Database
  Future<String> anhThanhBase64(XFile file) async {
    // 1. Đọc bytes gốc
    final Uint8List bytesGoc = await file.readAsBytes();

    // 2. Decode thành đối tượng Image (pure Dart, hoạt động trên Web)
    img.Image? anhGoc = img.decodeImage(bytesGoc);
    if (anhGoc == null) throw Exception('Không thể đọc ảnh.');

    // 3. Resize về tối đa 300x300 (giữ tỉ lệ)
    img.Image anhNho = img.copyResize(
      anhGoc,
      width:  anhGoc.width > anhGoc.height ? 300 : -1,
      height: anhGoc.height >= anhGoc.width ? 300 : -1,
    );

    // 4. Encode thành JPEG với quality 60%
    final List<int> bytesNen = img.encodeJpg(anhNho, quality: 60);

    // 5. Chuyển thành Base64 và trả về chuỗi data URL
    final String base64Str = base64Encode(bytesNen);
    return 'data:image/jpeg;base64,$base64Str';
  }
}
