import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../domain/entities/property.dart';
import '../models/property_model.dart';

class PropertyRemoteDatasource {
  static const String baseUrl = 'http://147.182.207.192:8003';
  static const String propertiesEndpoint = '/properties';

  final Dio _dio;

  PropertyRemoteDatasource(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> fetchProperties({
    int page = 1,
    int pageSize = 20,
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? tags,
    String? status,
  }) async {

    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
    )
    );
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (tags != null && tags.isNotEmpty) {
        queryParams['tags'] = tags;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        propertiesEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final properties = (data['properties'] as List?)
            ?.map((item) => PropertyModel.fromJson(item).toEntity())
            .toList() ?? [];
        final total = data['count'] as int? ?? 0;

        return {
          'properties': properties,
          'total': total,
          'page': page,
        };
      } else {
        throw Exception('Failed to fetch properties');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Property> fetchPropertyDetails(String propertyId) async {
    try {
      final response = await _dio.get('$propertiesEndpoint/$propertyId');

      if (response.statusCode == 200) {
        return PropertyModel.fromJson(response.data).toEntity();
      } else {
        throw Exception('Failed to fetch property details');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> uploadPropertyImage(String propertyId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'property_id': propertyId,
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        '$propertiesEndpoint/$propertyId/upload-image',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['image_url'] as String? ?? '';
      } else {
        throw Exception('Failed to upload image');
      }
    } on DioException catch (e) {
      throw Exception('Upload Error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<String>> fetchLocations() async {
    try {
      final response = await _dio.get('$propertiesEndpoint?location');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['locations'] as List? ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> fetchTags() async {
    try {
      final response = await _dio.get('$propertiesEndpoint?tags');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['tags'] as List? ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}