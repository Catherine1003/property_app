import 'package:dio/dio.dart';

class CommonUtil {
  static const String baseUrl = 'http://147.182.207.192:8003';
  static const String propertiesEndpoint = '/properties';

  Future<List<String>> fetchLocations() async {
    try {
      final response = await Dio().get('$propertiesEndpoint/locations');

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
      final response = await Dio().get('$propertiesEndpoint/tags');

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