import 'package:flutter/material.dart';

/// Bảng màu chung cho toàn bộ Quiz UI
/// Dựa theo Color Styles của dự án bảo tàng
class QuizColors {
  QuizColors._();

  // Nền
  static const background   = Color(0xFF1C1A17); // nền tối chính
  static const cardDark     = Color(0xFF2C2820); // card nền tối
  static const cardMedium   = Color(0xFF3A3228); // card phụ

  // Chữ & accent
  static const cream        = Color(0xFFF5ECD7); // chữ chính
  static const gold         = Color(0xFFC8A96E); // accent vàng gold
  static const goldLight    = Color(0xFFDDBE8A); // gold nhạt hơn

  // Trạng thái
  static const olive        = Color(0xFF7A8C5C); // đúng (xanh olive)
  static const oliveLight   = Color(0xFF9AAD74);
  static const brown        = Color(0xFF6B4F3A); // sai (nâu đỏ)
  static const brownLight   = Color(0xFF8C6B52);

  // Divider / border
  static const border       = Color(0xFF4A3F30);
  static const borderLight  = Color(0xFF5A4E3C);
}
