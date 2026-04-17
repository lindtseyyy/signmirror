import '../domain/contextual_zone.dart';

/// Maps a zone category to a small set of relevant vocabulary tokens.
///
/// This is a lightweight, static data source intended for early iterations.
const Map<ZoneCategory, List<String>> fslVocabByZoneCategory =
    <ZoneCategory, List<String>>{
      ZoneCategory.hospital: <String>[
        'Doctor',
        'Nurse',
        'Pain',
        'Emergency',
        'Medicine',
      ],
      ZoneCategory.market: <String>['Buy', 'Sell', 'Money', 'Food', 'Price'],
      ZoneCategory.school: <String>[
        'Teacher',
        'Student',
        'Learn',
        'Book',
        'Class',
      ],
      ZoneCategory.publicTransport: <String>[
        'Bus',
        'Train',
        'Ticket',
        'Stop',
        'Station',
      ],
    };
