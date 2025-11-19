import 'package:equatable/equatable.dart';
import '../../domain/entities/property.dart';

abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

class FetchPropertiesEvent extends PropertyEvent {
  final int page;
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final List<String>? tags;
  final String? status;
  final bool isRefresh;

  const FetchPropertiesEvent({
    this.page = 1,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.tags,
    this.status,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [
    page,
    minPrice,
    maxPrice,
    location,
    tags,
    status,
    isRefresh,
  ];
}

class LoadMorePropertiesEvent extends PropertyEvent {
  const LoadMorePropertiesEvent();
}

class FilterPropertiesEvent extends PropertyEvent {
  final PropertyFilter filter;

  const FilterPropertiesEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SearchPropertiesEvent extends PropertyEvent {
  final String query;

  const SearchPropertiesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ResetFiltersEvent extends PropertyEvent {
  const ResetFiltersEvent();
}

class FetchPropertyDetailsEvent extends PropertyEvent {
  final String propertyId;

  const FetchPropertyDetailsEvent(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class UploadPropertyImageEvent extends PropertyEvent {
  final String propertyId;
  final String imagePath;

  const UploadPropertyImageEvent({
    required this.propertyId,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [propertyId, imagePath];
}

class TrackPropertyInteractionEvent extends PropertyEvent {
  final String propertyId;
  final String action;

  const TrackPropertyInteractionEvent({
    required this.propertyId,
    required this.action,
  });

  @override
  List<Object?> get props => [propertyId, action];
}

class FetchLocationsEvent extends PropertyEvent {
  const FetchLocationsEvent();
}

class FetchTagsEvent extends PropertyEvent {
  const FetchTagsEvent();
}

class FetchMostViewedEvent extends PropertyEvent {
  const FetchMostViewedEvent();
}