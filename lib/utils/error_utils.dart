import 'package:flutter/material.dart';
import 'package:staymitra/utils/responsive_utils.dart';

class ErrorUtils {
  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: context.spacing(SpacingSize.sm)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: context.spacing(SpacingSize.sm)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            SizedBox(width: context.spacing(SpacingSize.sm)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            SizedBox(width: context.spacing(SpacingSize.sm)),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            SizedBox(width: context.spacing(SpacingSize.sm)),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Build error widget for failed states
  static Widget buildErrorWidget(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
    String retryText = 'Retry',
  }) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: context.responsiveIconSize(64),
              color: Colors.red[300],
            ),
            SizedBox(height: context.spacing(SpacingSize.md)),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing(SpacingSize.sm)),
            Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveFontSize(14),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.spacing(SpacingSize.lg)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(0.08),
                    vertical: context.responsiveHeight(0.015),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  static Widget buildEmptyWidget(
    BuildContext context,
    String message, {
    IconData icon = Icons.inbox_outlined,
    VoidCallback? onAction,
    String actionText = 'Add New',
  }) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.responsiveIconSize(64),
              color: Colors.grey[400],
            ),
            SizedBox(height: context.spacing(SpacingSize.md)),
            Text(
              message,
              style: TextStyle(
                fontSize: context.responsiveFontSize(16),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              SizedBox(height: context.spacing(SpacingSize.lg)),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(0.08),
                    vertical: context.responsiveHeight(0.015),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handle and format error messages
  static String formatErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';
    
    String errorString = error.toString();
    
    // Handle common Supabase errors
    if (errorString.contains('duplicate key value')) {
      return 'This item already exists';
    } else if (errorString.contains('violates foreign key constraint')) {
      return 'Invalid reference to another item';
    } else if (errorString.contains('permission denied')) {
      return 'You don\'t have permission to perform this action';
    } else if (errorString.contains('network')) {
      return 'Network error. Please check your connection';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again';
    } else if (errorString.contains('not found')) {
      return 'The requested item was not found';
    }
    
    // Return a user-friendly version of the error
    return errorString.length > 100 
        ? 'An error occurred. Please try again'
        : errorString;
  }
}
