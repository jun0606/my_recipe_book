import 'package:flutter/material.dart';

class ErrorHandler {
  static void logError(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    print('[$tag] ERROR: $message');
    if (error != null) {
      print('[$tag] ERROR DETAILS: $error');
    }
    if (stackTrace != null) {
      print('[$tag] STACK TRACE: $stackTrace');
    }
  }
  
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  static Future<bool> showConfirmationDialog(
    BuildContext context, 
    String title, 
    String content, 
    {String confirmText = '확인', String cancelText = '취소'}
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}