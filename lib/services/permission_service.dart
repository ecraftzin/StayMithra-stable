import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request storage permissions based on Android version
  Future<bool> requestStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true; // iOS handles permissions differently
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      print('Android SDK version: $sdkInt');

      // Android 13+ (API 33+) - Use granular media permissions
      if (sdkInt >= 33) {
        return await _requestAndroid13Permissions();
      }
      // Android 11-12 (API 30-32) - Use scoped storage
      else if (sdkInt >= 30) {
        return await _requestAndroid11Permissions();
      }
      // Android 10 and below - Use legacy storage permissions
      else {
        return await _requestLegacyPermissions();
      }
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }

  /// Request permissions for Android 13+ (API 33+)
  Future<bool> _requestAndroid13Permissions() async {
    print('Requesting Android 13+ permissions');
    
    final permissions = [
      Permission.photos, // READ_MEDIA_IMAGES
      Permission.videos, // READ_MEDIA_VIDEO
      Permission.camera,
    ];

    final statuses = await permissions.request();
    
    bool allGranted = true;
    for (final permission in permissions) {
      final status = statuses[permission];
      print('Permission $permission: $status');
      if (status != PermissionStatus.granted) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  /// Request permissions for Android 11-12 (API 30-32)
  Future<bool> _requestAndroid11Permissions() async {
    print('Requesting Android 11-12 permissions');
    
    final permissions = [
      Permission.storage,
      Permission.camera,
    ];

    final statuses = await permissions.request();
    
    bool allGranted = true;
    for (final permission in permissions) {
      final status = statuses[permission];
      print('Permission $permission: $status');
      if (status != PermissionStatus.granted) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  /// Request permissions for Android 10 and below (API 29-)
  Future<bool> _requestLegacyPermissions() async {
    print('Requesting legacy permissions');
    
    final permissions = [
      Permission.storage,
      Permission.camera,
    ];

    final statuses = await permissions.request();
    
    bool allGranted = true;
    for (final permission in permissions) {
      final status = statuses[permission];
      print('Permission $permission: $status');
      if (status != PermissionStatus.granted) {
        allGranted = false;
      }
    }

    return allGranted;
  }

  /// Check if storage permissions are granted
  Future<bool> hasStoragePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final photos = await Permission.photos.status;
        final camera = await Permission.camera.status;
        return photos.isGranted && camera.isGranted;
      } else {
        final storage = await Permission.storage.status;
        final camera = await Permission.camera.status;
        return storage.isGranted && camera.isGranted;
      }
    } catch (e) {
      print('Error checking storage permissions: $e');
      return false;
    }
  }

  /// Request camera permission specifically
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Open app settings if permissions are permanently denied
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
