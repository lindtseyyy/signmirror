import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

const String _profileAssetsPrefix = 'assets/images/profile/';
const String _legacyProfilePictureUrl = 'assets/images/profile_picture.jpeg';

Future<List<String>>? _cachedManifestKeys;

int _stableSeedFromString(String value) {
  // Stable across runs and platforms.
  // Keep it simple to avoid depending on Dart's `hashCode` (not stable).
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = 0x1fffffff & (hash + unit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= (hash >> 6);
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= (hash >> 11);
  hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  return hash;
}

Future<List<String>> _assetKeysFromManifest() async {
  final jsonString = await rootBundle.loadString('AssetManifest.json');
  final decoded = json.decode(jsonString);

  if (decoded is Map<String, dynamic>) {
    return decoded.keys.toList(growable: false);
  }

  // Extremely defensive: some older toolchains could emit a different shape.
  if (decoded is Map) {
    return decoded.keys.map((k) => k.toString()).toList(growable: false);
  }

  return const <String>[];
}

/// Picks a (seemingly) random profile placeholder asset path.
///
/// Uses `AssetManifest.json` via `rootBundle` so it only returns assets that
/// are actually bundled with the app.
///
/// If [stableKey] is provided, selection becomes deterministic for that key.
Future<String> pickRandomProfilePlaceholderAssetPath({
  String? stableKey,
}) async {
  List<String> keys;
  try {
    _cachedManifestKeys ??= _assetKeysFromManifest();
    keys = await _cachedManifestKeys!;
  } catch (_) {
    _cachedManifestKeys = null;
    return _legacyProfilePictureUrl;
  }

  List<String> profileAssets = keys
      .where((k) => k.startsWith(_profileAssetsPrefix))
      .toList(growable: false);

  // If the manifest did not yield profile assets, attempt a slightly broader
  // match (still preferring the profile directory).
  if (profileAssets.isEmpty) {
    profileAssets = keys
        .where((k) => k.contains('/images/profile/'))
        .toList(growable: false);
  }

  final rand = stableKey == null
      ? Random()
      : Random(_stableSeedFromString(stableKey));

  if (profileAssets.isNotEmpty) {
    return profileAssets[rand.nextInt(profileAssets.length)];
  }

  // Final fallback: return a known-good legacy asset path.
  return _legacyProfilePictureUrl;
}
