import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../localization/app_strings.dart';

class SupportTicketUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      case SupportTicketStatus.open:
        return const Color(0xFF68AC1C);
      case SupportTicketStatus.closed:
        return const Color(0xFFD04812);
      case SupportTicketStatus.reopen:
        return const Color(0xFFDBA417);
      case SupportTicketStatus.cancelled:
        return const Color(0xFFD04812);
      default:
        return const Color(0xFF68AC1C);
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case SupportTicketStatus.open:
        return getString(appStr.descriptionTicketOpen, 'description_ticket_open');
      case SupportTicketStatus.closed:
        return getString(
            appStr.descriptionTicketClosed, 'description_ticket_closed');
      case SupportTicketStatus.reopen:
        return getString(
            appStr.descriptionTicketReopen, 'description_ticket_reopen');
      case SupportTicketStatus.cancelled:
        return getString(
            appStr.descriptionTicketCancelled, 'description_ticket_cancelled');
      default:
        return status;
    }
  }
}
