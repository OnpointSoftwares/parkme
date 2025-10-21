import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching the design
  static const Color primaryDark = Color(0xFF3D4A5C);
  static const Color primaryYellow = Color(0xFFFDB846);
  static const Color darkBackground = Color(0xFF2C3847);
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF2C3847);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9CA3AF);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textLight,
    letterSpacing: 2,
  );
  
  static const TextStyle labelStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textLight,
  );
  
  static const TextStyle inputStyle = TextStyle(
    fontSize: 16,
    color: textDark,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textDark,
    letterSpacing: 1,
  );
  
  // Input Decoration
  static InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: inputBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryYellow, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
  
  // Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryYellow,
    foregroundColor: textDark,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: buttonTextStyle,
  );
  
  // Logo Widget
  static Widget logo({double size = 80}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'P',
          style: TextStyle(
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
            color: textLight,
          ),
        ),
      ),
    );
  }
}
