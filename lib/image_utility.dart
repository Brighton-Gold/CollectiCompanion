import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUtil {
  static Future<String?> pickAndConvertImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        File file = File(image.path);
        if (!file.existsSync()) {
          print("File does not exist");
          return null;
        }

        // Check if the file is a JPEG or PNG
        if (!isImageJpegOrPng(file)) {
          print("Unsupported file type. Only JPEG and PNG are allowed.");
          return null;
        }

        List<int> imageBytes = await file.readAsBytes();
        String base64Str = base64Encode(imageBytes);
        return base64Str;
      } else {
        print("Image picking was canceled or failed.");
        return null;
      }
    } catch (e) {
      print("An error occurred: $e");
      return null;
    }
  }

  static bool isImageJpegOrPng(File file) {
    return file.path.toLowerCase().endsWith('.jpg') || 
           file.path.toLowerCase().endsWith('.jpeg') || 
           file.path.toLowerCase().endsWith('.png');
  }
}
