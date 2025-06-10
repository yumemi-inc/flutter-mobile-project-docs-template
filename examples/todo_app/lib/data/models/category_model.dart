import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String color;
  final String? icon;
  final bool isPreset;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.isPreset,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      color: map['color'] as String,
      icon: map['icon'] as String?,
      isPreset: (map['is_preset'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
      'is_preset': isPreset ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      color: _parseColor(color),
      icon: icon != null ? _parseIcon(icon!) : null,
      isPreset: isPreset,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CategoryModel fromDomain(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      color: _colorToString(category.color),
      icon: category.icon != null ? _iconToString(category.icon!) : null,
      isPreset: category.isPreset,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  static Color _parseColor(String colorString) {
    // 色文字列を Color オブジェクトに変換
    switch (colorString.toLowerCase()) {
      case '青色':
      case 'blue':
        return Colors.blue;
      case '緑色':
      case 'green':
        return Colors.green;
      case 'オレンジ色':
      case 'orange':
        return Colors.orange;
      case '赤色':
      case 'red':
        return Colors.red;
      case '紫色':
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static String _colorToString(Color color) {
    // Color オブジェクトを文字列に変換
    if (color == Colors.blue) return '青色';
    if (color == Colors.green) return '緑色';
    if (color == Colors.orange) return 'オレンジ色';
    if (color == Colors.red) return '赤色';
    if (color == Colors.purple) return '紫色';
    return 'その他';
  }

  static IconData? _parseIcon(String iconString) {
    // アイコン文字列を IconData オブジェクトに変換
    switch (iconString) {
      case '🏢':
        return Icons.business;
      case '👤':
        return Icons.person;
      case '🛒':
        return Icons.shopping_cart;
      case '❤️':
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }

  static String _iconToString(IconData icon) {
    // IconData オブジェクトを文字列に変換
    if (icon == Icons.business) return '🏢';
    if (icon == Icons.person) return '👤';
    if (icon == Icons.shopping_cart) return '🛒';
    if (icon == Icons.favorite) return '❤️';
    return '📋';
  }
}
