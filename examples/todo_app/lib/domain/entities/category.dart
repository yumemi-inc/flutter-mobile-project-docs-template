import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final Color color;
  final IconData? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? name,
    Color? color,
    IconData? icon,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        color,
        icon,
        createdAt,
        updatedAt,
      ];
}

// プリセットカテゴリのファクトリー
class CategoryFactory {
  static List<Category> getDefaultCategories() {
    final now = DateTime.now();
    return [
      Category(
        id: 'work',
        name: '仕事',
        color: Colors.blue,
        icon: Icons.work,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'personal',
        name: '個人',
        color: Colors.green,
        icon: Icons.person,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'shopping',
        name: '買い物',
        color: Colors.orange,
        icon: Icons.shopping_cart,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: 'health',
        name: '健康',
        color: Colors.red,
        icon: Icons.favorite,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
