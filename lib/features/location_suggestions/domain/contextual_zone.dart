/// Domain model for contextual location zones used by location suggestions.
///
/// Notes:
/// - Coordinates are plain WGS84 latitude/longitude (degrees).
/// - This file intentionally contains no external dependencies.

enum ZoneCategory { hospital, market, school, publicTransport }

class ContextualZone {
  const ContextualZone({
    required this.id,
    required this.category,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
  });

  final String id;
  final ZoneCategory category;
  final String name;

  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  /// Radius of the zone in meters.
  ///
  /// Defaults to 100m.
  final int radiusMeters;

  @override
  String toString() {
    return 'ContextualZone(id: $id, category: $category, name: $name, '
        'latitude: $latitude, longitude: $longitude, radiusMeters: $radiusMeters)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ContextualZone &&
            other.id == id &&
            other.category == category &&
            other.name == name &&
            other.latitude == latitude &&
            other.longitude == longitude &&
            other.radiusMeters == radiusMeters);
  }

  @override
  int get hashCode =>
      Object.hash(id, category, name, latitude, longitude, radiusMeters);
}
