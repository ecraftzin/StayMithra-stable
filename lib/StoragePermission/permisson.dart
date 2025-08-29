import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class PermissionService {
  // Request storage permission
  Future<void> requestStoragePermission() async {
    // Check for the permission
    PermissionStatus status = await Permission.storage.request();

    // Check if permission is granted
    if (status.isGranted) {
      print("Storage permission granted");
    } else if (status.isDenied) {
      print("Storage permission denied");
    } else if (status.isPermanentlyDenied) {
      // Open settings to allow the user to manually grant permissions
      openAppSettings();
    }
  }

  // Pick an image after storage permission is granted
  Future<void> pickImage() async {
    // First request storage permission
    await requestStoragePermission();

    // If permission granted, pick an image
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("Picked image path: ${pickedFile.path}");
    } else {
      print("No image selected");
    }
  }
}
