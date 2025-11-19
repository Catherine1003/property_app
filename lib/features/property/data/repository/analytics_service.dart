import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AnalyticsService {
  static const String _viewsKey = 'property_views';
  static const String _interactionsKey = 'property_interactions';
  static const String _timeSpentKey = 'property_time_spent';

  final SharedPreferences _prefs;

  AnalyticsService(this._prefs);

  Future<void> trackPropertyView(String propertyId, String propertyTitle) async {
    try {
      final views = _getViews();
      final viewKey = 'view_$propertyId';

      if (views.containsKey(viewKey)) {
        views[viewKey] = {
          'id': propertyId,
          'title': propertyTitle,
          'count': (views[viewKey]?['count'] as int? ?? 0) + 1,
          'lastViewed': DateTime.now().toIso8601String(),
        };
      } else {
        views[viewKey] = {
          'id': propertyId,
          'title': propertyTitle,
          'count': 1,
          'lastViewed': DateTime.now().toIso8601String(),
        };
      }

      await _prefs.setString(_viewsKey, jsonEncode(views));
      print('📊 Tracked view for property: $propertyTitle');
    } catch (e) {
      print('❌ Error tracking view: $e');
    }
  }

  Future<void> trackPropertyInteraction(String propertyId, String action) async {
    try {
      final interactions = _getInteractions();
      final key = '${propertyId}_$action';

      if (interactions.containsKey(key)) {
        interactions[key] = (interactions[key] as int? ?? 0) + 1;
      } else {
        interactions[key] = 1;
      }

      await _prefs.setString(_interactionsKey, jsonEncode(interactions));
      print('📊 Tracked interaction: $action on property $propertyId');
    } catch (e) {
      print('❌ Error tracking interaction: $e');
    }
  }

  Future<void> trackTimeSpent(String propertyId, int seconds) async {
    try {
      final timeSpent = _getTimeSpent();
      final key = 'time_$propertyId';

      timeSpent[key] = (timeSpent[key] as int? ?? 0) + seconds;
      await _prefs.setString(_timeSpentKey, jsonEncode(timeSpent));
    } catch (e) {
      print('❌ Error tracking time spent: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMostViewedProperties() async {
    try {
      final views = _getViews();
      final list = views.values.toList();
      list.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      print('❌ Error getting most viewed properties: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getPropertyAnalytics(String propertyId) async {
    try {
      final views = _getViews();
      final interactions = _getInteractions();
      final timeSpent = _getTimeSpent();

      final viewKey = 'view_$propertyId';
      final viewData = views[viewKey] as Map<String, dynamic>? ?? {};

      final interactionKeys = interactions.keys
          .where((k) => k.startsWith('${propertyId}_'))
          .toList();
      int totalInteractions = 0;
      for (var key in interactionKeys) {
        totalInteractions += interactions[key] as int? ?? 0;
      }

      final timeKey = 'time_$propertyId';
      final totalSeconds = timeSpent[timeKey] as int? ?? 0;

      return {
        'propertyId': propertyId,
        'views': viewData['count'] ?? 0,
        'interactions': totalInteractions,
        'timeSpentSeconds': totalSeconds,
        'timeSpentMinutes': (totalSeconds / 60).toStringAsFixed(1),
      };
    } catch (e) {
      print('❌ Error getting property analytics: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getAllAnalytics() async {
    try {
      return {
        'views': _getViews(),
        'interactions': _getInteractions(),
        'timeSpent': _getTimeSpent(),
      };
    } catch (e) {
      print('❌ Error getting all analytics: $e');
      return {};
    }
  }

  Future<void> clearAnalytics() async {
    try {
      await _prefs.remove(_viewsKey);
      await _prefs.remove(_interactionsKey);
      await _prefs.remove(_timeSpentKey);
      print('✅ Analytics cleared');
    } catch (e) {
      print('❌ Error clearing analytics: $e');
    }
  }

  Map<String, dynamic> _getViews() {
    final json = _prefs.getString(_viewsKey) ?? '{}';
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Map<String, dynamic> _getInteractions() {
    final json = _prefs.getString(_interactionsKey) ?? '{}';
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Map<String, dynamic> _getTimeSpent() {
    final json = _prefs.getString(_timeSpentKey) ?? '{}';
    return jsonDecode(json) as Map<String, dynamic>;
  }
}