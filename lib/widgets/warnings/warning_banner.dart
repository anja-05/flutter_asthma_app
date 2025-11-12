import 'package:flutter/material.dart';

enum WarningSeverity { info, warning, danger }

class WarningBanner extends StatelessWidget {
  final String title;
  final String message;
  final WarningSeverity severity;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const WarningBanner({
    super.key,
    required this.title,
    required this.message,
    this.severity = WarningSeverity.info,
    this.onDismiss,
    this.onTap,
  });

  Color _getBackgroundColor() {
    switch (severity) {
      case WarningSeverity.info:
        return const Color(0xFF2196F3);
      case WarningSeverity.warning:
        return const Color(0xFFFFC107);
      case WarningSeverity.danger:
        return const Color(0xFFF44336);
    }
  }

  IconData _getIcon() {
    switch (severity) {
      case WarningSeverity.info:
        return Icons.info;
      case WarningSeverity.warning:
        return Icons.warning_amber_rounded;
      case WarningSeverity.danger:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getBackgroundColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}