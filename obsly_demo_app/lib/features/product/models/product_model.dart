import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Category extends Equatable {
  final int id;
  final String name;
  final String image;
  final String slug;

  const Category({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  @override
  List<Object?> get props => [id, name, image, slug];
}

@JsonSerializable()
class Product extends Equatable {
  final int id;
  final String title;
  final String slug;
  final num price;
  final String description;
  final Category category;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.slug,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    price,
    description,
    category,
    images,
  ];

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    slug: json['slug'] ?? '',
    price: json['price'],
    description: json['description'] ?? '',
    category: Category(
      id: json['category']['id'],
      name: json['category']['name'],
      image: json['category']['image'],
      slug: json['category']['slug'] ?? '',
    ),
    images: List<String>.from(json['images'] ?? []),
  );
}
