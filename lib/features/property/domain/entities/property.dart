import 'package:equatable/equatable.dart';

import 'location.dart';

class Property extends Equatable {
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

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.location,
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

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    location,
    status,
    views,
  ];

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    LocationData? location,
    String? status,
    List<String>? tags,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? images,
    List<String>? additionalImages,
    DateTime? createdAt,
    int? views,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      images: images ?? this.images,
      additionalImages: additionalImages ?? this.additionalImages,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
    );
  }
}

class PropertyFilter extends Equatable {
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final List<String> tags;
  final String? status;
  final int page;
  final int pageSize;

  const PropertyFilter({
    this.minPrice,
    this.maxPrice,
    this.location,
    this.tags = const [],
    this.status,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [
    minPrice,
    maxPrice,
    location,
    tags,
    status,
    page,
    pageSize,
  ];

  PropertyFilter copyWith({
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? tags,
    String? status,
    int? page,
    int? pageSize,
  }) {
    return PropertyFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

List<String> cities = [
  "Hillview",
  "Metrocity",
  "Beachside",
  "Townsburg",
  "Cityville"
];

List<String> tags = [
  "Pet Friendly",
  "Furnished",
  "Available",
  "Luxury",
  "New"
];