import 'package:equatable/equatable.dart';

import '../../domain/entities/property.dart';

abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

class PropertyInitial extends PropertyState {
  const PropertyInitial();
}

class PropertyLoading extends PropertyState {
  const PropertyLoading();
}

class PropertyLoadingMore extends PropertyState {
  final List<Property> properties;

  const PropertyLoadingMore(this.properties);

  @override
  List<Object?> get props => [properties];
}

class PropertyLoaded extends PropertyState {
  final List<Property> properties;
  final int totalCount;
  final int currentPage;
  final bool hasMore;
  final PropertyFilter currentFilter;

  const PropertyLoaded({
    required this.properties,
    required this.totalCount,
    required this.currentPage,
    required this.hasMore,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [
    properties,
    totalCount,
    currentPage,
    hasMore,
    currentFilter,
  ];
}

class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

class PropertyDetailsLoading extends PropertyState {
  const PropertyDetailsLoading();
}

class PropertyDetailsLoaded extends PropertyState {
  final Property property;

  const PropertyDetailsLoaded(this.property);

  @override
  List<Object?> get props => [property];
}

class PropertyDetailsError extends PropertyState {
  final String message;

  const PropertyDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImageUploadingState extends PropertyState {
  const ImageUploadingState();
}

class ImageUploadedState extends PropertyState {
  final String imageUrl;

  const ImageUploadedState(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

class ImageUploadErrorState extends PropertyState {
  final String message;

  const ImageUploadErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationsLoaded extends PropertyState {
  final List<String> locations;

  const LocationsLoaded(this.locations);

  @override
  List<Object?> get props => [locations];
}

class TagsLoaded extends PropertyState {
  final List<String> tags;

  const TagsLoaded(this.tags);

  @override
  List<Object?> get props => [tags];
}

class MostViewedPropertiesLoaded extends PropertyState {
  final List<Map<String, dynamic>> properties;

  const MostViewedPropertiesLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}