import 'package:flutter/material.dart';
import 'package:staymitra/services/first_time_permission_service.dart';

/// Helper class for testing permission flows
/// This should only be used during development/testing
class PermissionTestHelper {
  static final FirstTimePermissionService _permissionService = FirstTimePermissionService();

  /// Show a debug dialog with permission testing options
  static void showPermissionTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: Colors.orange),
            SizedBox(width: 8),
            Text('Permission Testing'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset permission tracking to test first-time flows:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildTestOption(
              context,
              'Reset All Permissions',
              'Clear all permission tracking data',
              Icons.refresh,
              () async {
                await _permissionService.resetPermissionTracking();
                Navigator.pop(context);
                _showSuccessMessage(context, 'All permission tracking reset!');
              },
            ),
            const SizedBox(height: 12),
            _buildTestOption(
              context,
              'Check Permission Status',
              'View current permission tracking status',
              Icons.info,
              () async {
                Navigator.pop(context);
                await _showPermissionStatus(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildTestOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF007F8C), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _showPermissionStatus(BuildContext context) async {
    final isFirstTimeStorage = await _permissionService.isFirstTimeStorageRequest();
    final isFirstTimeCamera = await _permissionService.isFirstTimeCameraRequest();
    final hasBeenExplained = await _permissionService.hasPermissionBeenExplained();

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permission Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow('Storage First Time', isFirstTimeStorage),
              _buildStatusRow('Camera First Time', isFirstTimeCamera),
              _buildStatusRow('Explanation Shown', !hasBeenExplained),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  static Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text('$label: '),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: value ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
