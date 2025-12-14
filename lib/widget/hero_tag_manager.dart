import 'package:flutter/material.dart';

/// Utility class to manage Hero widget tags and prevent conflicts
class HeroTagManager {
  static final Map<String, int> _tagCounters = {};

  /// Generates a unique hero tag for a service card
  static String generateServiceCardTag(Map<String, dynamic> service) {
    final String baseTag =
        'service_card_${service['id'] ?? service['title'] ?? 'unknown'}';
    return _generateUniqueTag(baseTag);
  }

  /// Generates a unique hero tag for a map marker
  static String generateMapMarkerTag(int index, String type) {
    final String baseTag = 'map_marker_${type}_$index';
    return _generateUniqueTag(baseTag);
  }

  /// Generates a unique hero tag for an image
  static String generateImageTag(String imageUrl, int index) {
    final String baseTag = 'image_${imageUrl.hashCode}_$index';
    return _generateUniqueTag(baseTag);
  }

  /// Generates a unique hero tag for any widget
  static String generateUniqueTag(String baseTag) {
    if (!_tagCounters.containsKey(baseTag)) {
      _tagCounters[baseTag] = 0;
    }
    _tagCounters[baseTag] = _tagCounters[baseTag]! + 1;
    return '${baseTag}_${_tagCounters[baseTag]}';
  }

  /// Private method to generate unique tags
  static String _generateUniqueTag(String baseTag) {
    if (!_tagCounters.containsKey(baseTag)) {
      _tagCounters[baseTag] = 0;
    }
    _tagCounters[baseTag] = _tagCounters[baseTag]! + 1;
    return '${baseTag}_${_tagCounters[baseTag]}';
  }

  /// Clears all tag counters (useful for testing or resetting)
  static void clearCounters() {
    _tagCounters.clear();
  }

  /// Gets the current count for a specific base tag
  static int getTagCount(String baseTag) {
    return _tagCounters[baseTag] ?? 0;
  }
}

/// Extension to add Hero widget functionality to any widget
extension HeroWidgetExtension on Widget {
  /// Wraps a widget with a Hero widget using a unique tag
  Widget withHero(String tag) {
    return Hero(tag: tag, child: this);
  }

  /// Wraps a widget with a Hero widget using a generated unique tag
  Widget withUniqueHero(String baseTag) {
    return Hero(tag: HeroTagManager.generateUniqueTag(baseTag), child: this);
  }
}
