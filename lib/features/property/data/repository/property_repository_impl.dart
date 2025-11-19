import '../../domain/entities/property.dart';
import '../datasource/property_remote_datasource.dart';
import 'analytics_service.dart';

class PropertyRepositoryImpl {
  final PropertyRemoteDatasource apiService;
  final AnalyticsService analyticsService;

  PropertyRepositoryImpl({
    required this.apiService,
    required this.analyticsService,
  });

  Future<Map<String, dynamic>> getProperties({
    int page = 1,
    int pageSize = 20,
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? tags,
    String? status,
  }) async {
    return await apiService.fetchProperties(
      page: page,
      pageSize: pageSize,
      minPrice: minPrice,
      maxPrice: maxPrice,
      location: location,
      tags: tags,
      status: status,
    );
  }
  Future<void> trackPropertyInteraction(String propertyId, String action) async {
    await analyticsService.trackPropertyInteraction(
      propertyId,
      action,
    );
  }

  Future<List<Map<String, dynamic>>> getMostViewedProperties() async {
    return await analyticsService.getMostViewedProperties();
  }

  Future<Map<String, dynamic>> getPropertyAnalytics(String propertyId) async {
    return await analyticsService.getPropertyAnalytics(propertyId);
  }
}