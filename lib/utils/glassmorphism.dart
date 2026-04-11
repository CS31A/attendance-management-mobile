import 'package:flutter/material.dart';
import 'dart:ui';

/// Glassmorphism utility for creating frosted glass effects
class Glassmorphism {
  /// Create a glassmorphic container with blur effect
  static Widget container({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
    Color color = Colors.white,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    Border? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  /// Create a glassmorphic card
  static Widget card({
    required Widget child,
    double blur = 10,
    double opacity = 0.1,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    VoidCallback? onTap,
  }) {
    final card = container(
      child: child,
      blur: blur,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }

  /// Create a glassmorphic button
  static Widget button({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    double blur = 10,
    double opacity = 0.15,
    double borderRadius = 12,
    Color textColor = Colors.white,
    double fontSize = 16,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        blur: blur,
        opacity: opacity,
        borderRadius: borderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
