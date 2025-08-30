import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class FirstTimePermissionService {
  static const String _storagePermissionRequestedKey = 'storage_permission_requested';
  static const String _cameraPermissionRequestedKey = 'camera_permission_requested';
  static const String _permissionExplainedKey = 'permission_explained';

  /// Check if this is the first time requesting storage permissions
  Future<bool> isFirstTimeStorageRequest() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_storagePermissionRequestedKey) ?? false);
  }

  /// Check if this is the first time requesting camera permissions
  Future<bool> isFirstTimeCameraRequest() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_cameraPermissionRequestedKey) ?? false);
  }

  /// Mark storage permission as requested
  Future<void> markStoragePermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storagePermissionRequestedKey, true);
  }

  /// Mark camera permission as requested
  Future<void> markCameraPermissionRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cameraPermissionRequestedKey, true);
  }

  /// Check if permission explanation has been shown
  Future<bool> hasPermissionBeenExplained() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionExplainedKey) ?? false;
  }

  /// Mark permission explanation as shown
  Future<void> markPermissionExplained() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionExplainedKey, true);
  }

  /// Show first-time permission explanation dialog
  Future<bool> showFirstTimePermissionExplanation(
    BuildContext context,
    String permissionType,
  ) async {
    final hasBeenExplained = await hasPermissionBeenExplained();
    
    if (hasBeenExplained) {
      return true; // Skip explanation if already shown
    }

    final shouldProceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              permissionType == 'storage' ? Icons.photo_library : Icons.camera_alt,
              color: const Color(0xFF007F8C),
            ),
            const SizedBox(width: 8),
            Text(
              permissionType == 'storage' ? 'Photo Access' : 'Camera Access',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              permissionType == 'storage'
                  ? 'StayMithra needs access to your photos to:'
                  : 'StayMithra needs camera access to:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildPermissionReason(
              Icons.add_photo_alternate,
              permissionType == 'storage'
                  ? 'Select photos for your posts and profile'
                  : 'Take photos for posts and profile',
            ),
            const SizedBox(height: 8),
            _buildPermissionReason(
              Icons.share,
              'Share memories with your community',
            ),
            const SizedBox(height: 8),
            _buildPermissionReason(
              Icons.security,
              'Your photos remain private and secure',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You can change these permissions anytime in your device settings.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007F8C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (shouldProceed == true) {
      await markPermissionExplained();
    }

    return shouldProceed ?? false;
  }

  Widget _buildPermissionReason(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// Request storage permissions with first-time handling
  Future<bool> requestStoragePermissionsFirstTime(BuildContext context) async {
    try {
      final isFirstTime = await isFirstTimeStorageRequest();
      
      if (isFirstTime) {
        // Show explanation dialog first
        final shouldProceed = await showFirstTimePermissionExplanation(
          context,
          'storage',
        );
        
        if (!shouldProceed) {
          return false;
        }
      }

      // Mark as requested
      await markStoragePermissionRequested();

      // Request actual permissions
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      List<Permission> permissions = [];
      
      if (sdkInt >= 33) {
        // Android 13+ granular permissions
        permissions = [
          Permission.photos,
          Permission.videos,
        ];
      } else {
        // Legacy permission
        permissions = [Permission.storage];
      }

      Map<Permission, PermissionStatus> statuses = await permissions.request();
      
      // Check if all permissions are granted
      bool allGranted = statuses.values.every((status) => status.isGranted);
      
      if (!allGranted && context.mounted) {
        // Show helpful message if permissions denied
        _showPermissionDeniedDialog(context, 'storage');
      }
      
      return allGranted;
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }

  /// Request camera permissions with first-time handling
  Future<bool> requestCameraPermissionsFirstTime(BuildContext context) async {
    try {
      final isFirstTime = await isFirstTimeCameraRequest();
      
      if (isFirstTime) {
        // Show explanation dialog first
        final shouldProceed = await showFirstTimePermissionExplanation(
          context,
          'camera',
        );
        
        if (!shouldProceed) {
          return false;
        }
      }

      // Mark as requested
      await markCameraPermissionRequested();

      // Request actual permission
      final status = await Permission.camera.request();
      
      if (!status.isGranted && context.mounted) {
        _showPermissionDeniedDialog(context, 'camera');
      }
      
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permissions: $e');
      return false;
    }
  }

  /// Show permission denied dialog with helpful guidance
  void _showPermissionDeniedDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('Permission Needed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              permissionType == 'storage'
                  ? 'To select photos, please allow photo access in your device settings.'
                  : 'To take photos, please allow camera access in your device settings.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to enable:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('1. Go to Settings > Apps > StayMithra'),
                  Text('2. Tap Permissions'),
                  Text('3. Enable the required permission'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007F8C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Reset all permission tracking (for testing purposes)
  Future<void> resetPermissionTracking() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storagePermissionRequestedKey);
    await prefs.remove(_cameraPermissionRequestedKey);
    await prefs.remove(_permissionExplainedKey);
  }
}
