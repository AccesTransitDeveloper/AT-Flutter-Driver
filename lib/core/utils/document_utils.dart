import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../../viewmodels/document_viewmodel.dart';
import 'date_utils.dart';

/// Document utility functions
class DocumentUtils {
  /// Get status color based on document status
  static Color getStatusColor(int? statusValue, {BuildContext? context}) {
    final status = DocumentStatus.fromValue(statusValue);
    switch (status) {
      case DocumentStatus.accepted:
        return Colors.green;
      case DocumentStatus.rejected:
      case DocumentStatus.expired:
        return Colors.red;
      case DocumentStatus.pending:
      case DocumentStatus.uploaded:
        return context?.colors.colorText ?? Colors.black;
    }
  }

  /// Get status display text
  static String getStatusText(int? statusValue) {
    return DocumentStatus.fromValue(statusValue).displayText;
  }

  /// Check if document has expired based on expiry date
  static bool isExpired(String? expiryDate) {
    if (expiryDate == null || expiryDate.isEmpty) return false;
    final expiry = AppDateUtils.parse(expiryDate);
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  /// Format expiry date for display (dd-MM-yyyy)
  static String formatExpiryDate(String? expiryDate) {
    return AppDateUtils.formatString(expiryDate, DateFormat.dateOnlyFormat);
  }
}
