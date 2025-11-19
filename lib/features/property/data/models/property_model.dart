import '../../domain/entities/location.dart';
import '../../domain/entities/property.dart';

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final LocationData? location;
  final String status;
  final List<String> tags;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> images;
  final List<String> additionalImages;
  final DateTime createdAt;
  final int views;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.status,
    required this.tags,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.images,
    required this.additionalImages,
    required this.createdAt,
    required this.views,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? "",
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: LocationData.fromJson(json["location"]),
      status: json['status'] as String? ?? 'Available',
      tags: List<String>.from(json['tags'] as List? ?? []),
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      area: (json['areaSqFt'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] as List? ?? []),
      additionalImages: List<String>.from(
        json['additional_images'] as List? ?? json['additionalImages'] as List? ?? [],
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      views: json['views'] as int? ?? 0,
    );
  }

  Property toEntity() => Property(
    id: id,
    title: title,
    description: description,
    price: price,
    location: location,
    status: status,
    tags: tags,
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    area: area,
    images: images,
    additionalImages: additionalImages,
    createdAt: createdAt,
    views: views,
  );
}

