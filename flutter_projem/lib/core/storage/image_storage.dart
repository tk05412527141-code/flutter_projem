import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImageStorage {
  Future<String?> pickAndSaveImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;
    final Directory dir = await getApplicationDocumentsDirectory();
    final String imagesDir = p.join(dir.path, 'images');
    await Directory(imagesDir).create(recursive: true);
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}';
    final String newPath = p.join(imagesDir, fileName);
    await File(picked.path).copy(newPath);
    return newPath;
  }
}