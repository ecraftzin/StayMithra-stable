import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // Check if we need to request storage permissions based on Android version
  bool _needsStoragePermissions() {
    if (!Platform.isAndroid) return false;
    
    // For Android 13+ (API 33+), we use granular media permissions
    // For older versions, we use legacy storage permissions
    return true;
  }

  // Get the appropriate permissions based on Android version
  List<Permission> _getStoragePermissions() {
    if (!Platform.isAndroid) return [];

    // For Android 13+ (API 33+), use granular media permissions
    if (Platform.version.contains('33') || 
        Platform.version.contains('34') ||
        Platform.version.contains('35')) {
      return [
        Permission.photos,
        Permission.videos,
        Permission.camera,
      ];
    }
    
    // For older Android versions, use legacy storage permissions
    return [
      Permission.storage,
      Permission.camera,
    ];
  }

  // Request storage permissions for media uploads
  Future<bool> requestStoragePermissions({BuildContext? context}) async {
    if (!_needsStoragePermissions()) return true;

    try {
      final permissions = _getStoragePermissions();
      final statuses = await permissions.request();
      
      bool allGranted = true;
      for (final permission in permissions) {
        final status = statuses[permission];
        if (status != PermissionStatus.granted) {
          allGranted = false;
          break;
        }
      }

      if (!allGranted && context != null) {
        await _showPermissionDialog(context, permissions, statuses);
      }

      return allGranted;
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return false;
    }
  }

  // Check if storage permissions are granted
  Future<bool> hasStoragePermissions() async {
    if (!_needsStoragePermissions()) return true;

    try {
      final permissions = _getStoragePermissions();
      
      for (final permission in permissions) {
        final status = await permission.status;
        if (status != PermissionStatus.granted) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      print('Error checking storage permissions: $e');
      return false;
    }
  }

  // Request camera permission specifically
  Future<bool> requestCameraPermission({BuildContext? context}) async {
    try {
      final status = await Permission.camera.request();
      
      if (status != PermissionStatus.granted && context != null) {
        await _showCameraPermissionDialog(context, status);
      }
      
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  // Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  // Request all media-related permissions at once
  Future<bool> requestAllMediaPermissions({BuildContext? context}) async {
    try {
      final storageGranted = await requestStoragePermissions(context: context);
      final cameraGranted = await requestCameraPermission(context: context);
      
      return storageGranted && cameraGranted;
    } catch (e) {
      print('Error requesting all media permissions: $e');
      return false;
    }
  }

  // Show permission explanation dialog
  Future<void> _showPermissionDialog(
    BuildContext context,
    List<Permission> permissions,
    Map<Permission, PermissionStatus> statuses,
  ) async {
    final deniedPermissions = <String>[];
    final permanentlyDeniedPermissions = <String>[];

    for (final permission in permissions) {
      final status = statuses[permission];
      final name = _getPermissionName(permission);
      
      if (status == PermissionStatus.denied) {
        deniedPermissions.add(name);
      } else if (status == PermissionStatus.permanentlyDenied) {
        permanentlyDeniedPermissions.add(name);
      }
    }

    if (deniedPermissions.isNotEmpty || permanentlyDeniedPermissions.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permissions Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'StayMithra needs the following permissions to upload photos and videos:',
                ),
                const SizedBox(height: 16),
                if (deniedPermissions.isNotEmpty) ...[
                  const Text(
                    'Denied permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...deniedPermissions.map((name) => Text('• $name')),
                  const SizedBox(height: 8),
                ],
                if (permanentlyDeniedPermissions.isNotEmpty) ...[
                  const Text(
                    'Please enable these permissions in Settings:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...permanentlyDeniedPermissions.map((name) => Text('• $name')),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              if (permanentlyDeniedPermissions.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              if (deniedPermissions.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    requestStoragePermissions(context: context);
                  },
                  child: const Text('Grant Permissions'),
                ),
            ],
          );
        },
      );
    }
  }

  // Show camera permission dialog
  Future<void> _showCameraPermissionDialog(
    BuildContext context,
    PermissionStatus status,
  ) async {
    if (status == PermissionStatus.denied || 
        status == PermissionStatus.permanentlyDenied) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Camera Permission Required'),
            content: Text(
              status == PermissionStatus.permanentlyDenied
                  ? 'Camera permission is permanently denied. Please enable it in Settings to take photos.'
                  : 'StayMithra needs camera permission to take photos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (status == PermissionStatus.permanentlyDenied) {
                    openAppSettings();
                  } else {
                    requestCameraPermission(context: context);
                  }
                },
                child: Text(
                  status == PermissionStatus.permanentlyDenied
                      ? 'Open Settings'
                      : 'Grant Permission',
                ),
              ),
            ],
          );
        },
      );
    }
  }

  // Get human-readable permission name
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.storage:
        return 'Storage Access';
      case Permission.photos:
        return 'Photos Access';
      case Permission.videos:
        return 'Videos Access';
      case Permission.camera:
        return 'Camera Access';
      default:
        return 'Media Access';
    }
  }

  // Initialize permissions on app start
  Future<void> initializePermissions() async {
    try {
      // Check current permission status without requesting
      final hasStorage = await hasStoragePermissions();
      final hasCamera = await hasCameraPermission();
      
      print('Storage permissions: ${hasStorage ? 'Granted' : 'Not granted'}');
      print('Camera permission: ${hasCamera ? 'Granted' : 'Not granted'}');
    } catch (e) {
      print('Error initializing permissions: $e');
    }
  }
}
