import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final int colorValue;
  final int? iconCodePoint;
  final int createdAt;
  final int updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconCodePoint,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      iconCodePoint: map['icon_code_point'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      color: Color(colorValue),
      icon: iconCodePoint != null
          ? IconData(iconCodePoint!, fontFamily: 'MaterialIcons')
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  static CategoryModel fromDomain(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      colorValue: category.color.value,
      iconCodePoint: category.icon?.codePoint,
      createdAt: category.createdAt.millisecondsSinceEpoch,
      updatedAt: category.updatedAt.millisecondsSinceEpoch,
    );
  }
}
