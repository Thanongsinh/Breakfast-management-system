import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  // สำหรับ emulator: http://10.0.2.2:8080/api
  // สำหรับ device จริง: http://<YOUR_LOCAL_IP>:8080/api
  static const String apiBaseUrl = 'http://10.0.2.2:8080/api';
  static const String apiVersion = 'v1';

  // Color Constants
  static const Color ownerPrimary = Color(0xFF2563EB); // Blue
  static const Color tenantPrimary = Color(0xFF7C3AED); // Purple

  static const Color ownerSecondary = Color(0xFF1E40AF);
  static const Color tenantSecondary = Color(0xFF6D28D9);

  static const Color ownerLight = Color(0xFFDBEAFE);
  static const Color tenantLight = Color(0xFFEDE9FE);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E7EB);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;

  // Payment Methods
  static const List<String> paymentMethods = [
    'cash',
    'bank_transfer',
    'e-wallet',
  ];

  // Bill Status
  static const List<String> billStatuses = [
    'pending',
    'paid',
    'overdue',
    'cancelled',
  ];

  // Maintenance Categories
  static const List<String> maintenanceCategories = [
    'plumbing',
    'electrical',
    'furniture',
    'other',
  ];

  // Maintenance Priorities
  static const List<String> maintenancePriorities = [
    'low',
    'medium',
    'high',
    'urgent',
  ];

  // Maintenance Statuses
  static const List<String> maintenanceStatuses = [
    'pending',
    'in_progress',
    'completed',
    'cancelled',
  ];

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Helper Methods
  static Color getPrimaryColor(String role) {
    return role == 'owner' ? ownerPrimary : tenantPrimary;
  }

  static Color getSecondaryColor(String role) {
    return role == 'owner' ? ownerSecondary : tenantSecondary;
  }

  static Color getLightColor(String role) {
    return role == 'owner' ? ownerLight : tenantLight;
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'confirmed':
      case 'completed':
      case 'active':
        return successColor;
      case 'pending':
      case 'in_progress':
        return warningColor;
      case 'overdue':
      case 'rejected':
      case 'cancelled':
      case 'expired':
        return errorColor;
      default:
        return infoColor;
    }
  }

  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
