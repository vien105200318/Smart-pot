import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  // Hàm 1: Chọn ảnh từ máy
  static Future<File?> pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return null;
    return File(image.path);
  }

  // Hàm 2: Úp ảnh lên Cloudinary
  static Future<String?> uploadToCloudinary(File imageFile) async {
    // Thông tin tài khoản của ông
    const cloudName = 'dotbbbwyw'; 
    const uploadPreset = 'yn5gea2y'; 

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        
        // Trả về cái link ảnh xịn xò (bắt đầu bằng https://...)
        return jsonMap['secure_url']; 
      } else {
        print('Lỗi Upload Cloudinary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Lỗi mạng Cloudinary: $e');
      return null;
    }
  }
}