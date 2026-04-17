import '../domain/contextual_zone.dart';

/// Predefined sample zones for development/testing.
///
/// The coordinates below are intentionally *placeholder values* (not real-world
/// locations). They’re named to make that explicit.
const double _placeholderLatitudeA = 14.589194;
const double _placeholderLongitudeA = 121.113016;

const double _placeholderLatitudeB = 37.00020;
const double _placeholderLongitudeB = -122.00020;

const double _placeholderLatitudeC = 37.00030;
const double _placeholderLongitudeC = -122.00030;

const double _placeholderLatitudeD = 37.00040;
const double _placeholderLongitudeD = -122.00040;

/// A small predefined list of contextual zones.
///
/// Includes at least one sample zone per [ZoneCategory].
const List<ContextualZone> predefinedContextualZones = <ContextualZone>[
  ContextualZone(
    id: 'zone_hospital_001',
    category: ZoneCategory.hospital,
    name: 'Sample Hospital Zone',
    latitude: _placeholderLatitudeA,
    longitude: _placeholderLongitudeA,
    radiusMeters: 150,
  ),
  ContextualZone(
    id: 'zone_market_001',
    category: ZoneCategory.market,
    name: 'Sample Market Zone',
    latitude: _placeholderLatitudeB,
    longitude: _placeholderLongitudeB,
  ),
  ContextualZone(
    id: 'zone_school_001',
    category: ZoneCategory.school,
    name: 'Sample School Zone',
    latitude: _placeholderLatitudeC,
    longitude: _placeholderLongitudeC,
    radiusMeters: 120,
  ),
  ContextualZone(
    id: 'zone_public_transport_001',
    category: ZoneCategory.publicTransport,
    name: 'Sample Public Transport Zone',
    latitude: _placeholderLatitudeD,
    longitude: _placeholderLongitudeD,
  ),
];
