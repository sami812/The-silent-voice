import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<String> uploadToCloudinary(Uint8List imageBytes) async {
  const cloudName = 'dw2sobh38';
  const uploadPreset = 'zawfyben';
  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
  final request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromBytes('file', imageBytes, filename: 'image.jpg'));
  request.fields['upload_preset'] = uploadPreset;
  final response = await request.send();
  final responseBody = await response.stream.bytesToString();
  if(response.statusCode != 200){
    throw Exception('Failed to upload image to Cloudinary');
  }
  final imageUrl = RegExp(r'"secure_url":"(.*?)"').firstMatch(responseBody)?.group(1);
  return imageUrl ?? '';
}
