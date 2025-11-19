import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/property_repository_impl.dart';
import '../../domain/entities/property.dart';
import 'property_event.dart';
import 'property_state.dart';

class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final PropertyRepositoryImpl repository;

  List<Property> _allProperties = [];
  int _currentPage = 1;
  int _totalCount = 0;
  PropertyFilter _currentFilter = const PropertyFilter();

  PropertyBloc({required this.repository}) : super(const PropertyInitial()) {
    on<FetchPropertiesEvent>(_onFetchProperties);
    on<LoadMorePropertiesEvent>(_onLoadMore);
    on<FilterPropertiesEvent>(_onFilter);
    on<ResetFiltersEvent>(_onResetFilters);
    on<FetchPropertyDetailsEvent>(_onFetchDetails);
    on<UploadPropertyImageEvent>(_onUploadImage);
    on<TrackPropertyInteractionEvent>(_onTrackInteraction);
    on<FetchLocationsEvent>(_onFetchLocations);
    on<FetchTagsEvent>(_onFetchTags);
    on<FetchMostViewedEvent>(_onFetchMostViewed);
  }

  Future<void> _onFetchProperties(
      FetchPropertiesEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {

      if (event.isRefresh) {
        emit(const PropertyLoading());
      }

      final filter = _currentFilter.copyWith(
        minPrice: event.minPrice ?? _currentFilter.minPrice,
        maxPrice: event.maxPrice ?? _currentFilter.maxPrice,
        location: event.location ?? _currentFilter.location,
        tags: event.tags ?? _currentFilter.tags,
        status: event.status ?? _currentFilter.status,
        page: event.isRefresh ? 1 : event.page,
      );

      _currentFilter = filter;
      _currentPage = event.isRefresh ? 1 : event.page;

      if (event.isRefresh) {
        _allProperties.clear();
      }

      final result = await repository.getProperties(
        page: filter.page,
        pageSize: filter.pageSize,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        location: filter.location,
        tags: filter.tags.isEmpty ? null : filter.tags,
        status: filter.status,
      );

      final fetched = result['properties'] as List<Property>;

      if (event.isRefresh) {
        _allProperties = List<Property>.from(fetched);
      } else {
        _allProperties.addAll(fetched);
      }

      _totalCount = result['total'] as int;
      final hasMore = _allProperties.length < _totalCount;

      emit(PropertyLoaded(
        properties: _allProperties,
        totalCount: _totalCount,
        currentPage: _currentPage,
        hasMore: hasMore,
        currentFilter: _currentFilter,
      ));
    } catch (e) {
      emit(PropertyError('Failed to load properties: $e'));
    }
  }

  Future<void> _onLoadMore(
      LoadMorePropertiesEvent event,
      Emitter<PropertyState> emit,
      ) async {
    if (state is! PropertyLoaded) {

      return;
    }

    final currentState = state as PropertyLoaded;

    if (!currentState.hasMore) {
      return;
    }

    try {

      _currentPage = currentState.currentPage + 1;
      _currentFilter = _currentFilter.copyWith(page: _currentPage);

      final result = await repository.getProperties(
        page: _currentPage,
        pageSize: _currentFilter.pageSize,
        minPrice: _currentFilter.minPrice,
        maxPrice: _currentFilter.maxPrice,
        location: _currentFilter.location,
        tags: _currentFilter.tags.isEmpty ? null : _currentFilter.tags,
        status: _currentFilter.status,
      );

      final newProperties = result['properties'] as List<Property>;

      _allProperties.addAll(newProperties);
      _totalCount = result['total'] as int? ?? _totalCount;

      final hasMore = _allProperties.length < _totalCount;

      emit(PropertyLoaded(
        properties: _allProperties,
        totalCount: _totalCount,
        currentPage: _currentPage,
        hasMore: hasMore,
        currentFilter: _currentFilter,
      ));
    } catch (e) {
      emit(PropertyError('Failed to load more: $e'));
    }
  }

  Future<void> _onFilter(
      FilterPropertiesEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      emit(const PropertyLoading());

      _currentFilter = event.filter;
      _currentPage = 1;
      _allProperties.clear();

      final result = await repository.getProperties(
        page: 1,
        pageSize: event.filter.pageSize,
        minPrice: event.filter.minPrice,
        maxPrice: event.filter.maxPrice,
        location: event.filter.location,
        tags: event.filter.tags.isEmpty ? null : event.filter.tags,
        status: event.filter.status,
      );

      _allProperties = List<Property>.from(result['properties'] as List);
      _totalCount = result['total'] as int;
      final hasMore = _allProperties.length < _totalCount;

      emit(PropertyLoaded(
        properties: _allProperties,
        totalCount: _totalCount,
        currentPage: 1,
        hasMore: hasMore,
        currentFilter: _currentFilter,
      ));
    } catch (e) {
      emit(PropertyError('Filter failed: $e'));
    }
  }

  Future<void> _onResetFilters(
      ResetFiltersEvent event,
      Emitter<PropertyState> emit,
      ) async {
    _currentFilter = const PropertyFilter();
    _currentPage = 1;
    _allProperties.clear();


    add(const FetchPropertiesEvent(isRefresh: true));
  }

  Future<void> _onFetchDetails(
      FetchPropertyDetailsEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      emit(const PropertyDetailsLoading());
      final property = await repository.getPropertyDetails(event.propertyId);
      emit(PropertyDetailsLoaded(property));
    } catch (e) {
      emit(PropertyDetailsError('Failed to load property: $e'));
    }
  }

  Future<void> _onUploadImage(
      UploadPropertyImageEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      emit(const ImageUploadingState());
      final imageUrl = await repository.uploadImage(
        event.propertyId,
        event.imagePath,
      );
      emit(ImageUploadedState(imageUrl));
    } catch (e) {
      emit(ImageUploadErrorState('Upload failed: $e'));
    }
  }

  Future<void> _onTrackInteraction(
      TrackPropertyInteractionEvent event,
      Emitter<PropertyState> emit,
      ) async {
    await repository.trackPropertyInteraction(
      event.propertyId,
      event.action,
    );
  }

  Future<void> _onFetchLocations(
      FetchLocationsEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      final locations = await repository.getLocations();
      emit(LocationsLoaded(locations));
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> _onFetchTags(
      FetchTagsEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      final tags = await repository.getTags();
      emit(TagsLoaded(tags));
    } catch (e) {
      print('Error fetching tags: $e');
    }
  }

  Future<void> _onFetchMostViewed(
      FetchMostViewedEvent event,
      Emitter<PropertyState> emit,
      ) async {
    try {
      final properties = await repository.getMostViewedProperties();
      emit(MostViewedPropertiesLoaded(properties));
    } catch (e) {
      print('Error fetching most viewed: $e');
    }
  }
}