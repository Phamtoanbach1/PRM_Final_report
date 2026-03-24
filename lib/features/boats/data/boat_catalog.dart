import '../domain/boat.dart';

class BoatCatalog {
  BoatCatalog._();

  static final defaultBoats = <Boat>[
    Boat(
      id: 'boat_han_01',
      name: 'Thuyền Hàn River 01',
      description: 'Du thuyền ngắm cầu Rồng buổi tối, phù hợp gia đình nhỏ.',
      capacity: 12,
      hourlyPrice: 850000,
      rating: 4.7,
      ownerEmail: 'owner@hancruise.local',
      gallery: <String>[
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        'https://images.unsplash.com/photo-1473448912268-2022ce9509d8',
        'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
      ],
      blockedDateYmd: <String>{'2026-03-26', '2026-03-29'},
    ),
    Boat(
      id: 'boat_han_02',
      name: 'Thuyền Hàn River 02',
      description: 'Không gian mở rộng, thích hợp nhóm bạn từ 6-15 người.',
      capacity: 18,
      hourlyPrice: 980000,
      rating: 4.8,
      ownerEmail: 'owner@hancruise.local',
      gallery: <String>[
        'https://images.unsplash.com/photo-1518834107812-67b0b7c58434',
        'https://images.unsplash.com/photo-1569263979104-865ab7cd8d13',
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21',
      ],
      blockedDateYmd: <String>{'2026-03-25'},
    ),
    Boat(
      id: 'boat_sunset',
      name: 'Thuyền Hoàng Hôn',
      description: 'Tour ngắm hoàng hôn riêng tư, phù hợp cặp đôi và gia đình.',
      capacity: 8,
      hourlyPrice: 720000,
      rating: 4.9,
      ownerEmail: 'owner2@hancruise.local',
      gallery: <String>[
        'https://images.unsplash.com/photo-1500375592092-40eb2168fd21',
        'https://images.unsplash.com/photo-1493558103817-58b2924bce98',
        'https://images.unsplash.com/photo-1497294815431-9365093b7331',
      ],
      blockedDateYmd: <String>{'2026-03-30'},
    ),
    Boat(
      id: 'boat_lux',
      name: 'Thuyền Luxury Cruise',
      description: 'Du thuyền cao cấp có khoang VIP và dịch vụ ăn tối.',
      capacity: 24,
      hourlyPrice: 1500000,
      rating: 5.0,
      ownerEmail: 'owner2@hancruise.local',
      gallery: <String>[
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
        'https://images.unsplash.com/photo-1519046904884-53103b34b206',
        'https://images.unsplash.com/photo-1521336575822-6da63fb45455',
      ],
      blockedDateYmd: <String>{'2026-03-24', '2026-03-31'},
    ),
    ..._demoFleet('owner@hancruise.local', 'A', 1),
    ..._demoFleet('owner2@hancruise.local', 'B', 13),
  ];

  static List<Boat> _demoFleet(String ownerEmail, String prefix, int startIndex) {
    const images = <String>[
      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
      'https://images.unsplash.com/photo-1518834107812-67b0b7c58434',
      'https://images.unsplash.com/photo-1544551763-46a013bb70d5',
      'https://images.unsplash.com/photo-1519046904884-53103b34b206',
      'https://images.unsplash.com/photo-1521336575822-6da63fb45455',
      'https://images.unsplash.com/photo-1493558103817-58b2924bce98',
      'https://images.unsplash.com/photo-1497294815431-9365093b7331',
      'https://images.unsplash.com/photo-1439066615861-d1af74d74000',
    ];
    return List<Boat>.generate(12, (i) {
      final n = startIndex + i;
      final cap = 8 + (i % 6) * 3;
      final price = 700000 + (i % 8) * 120000;
      return Boat(
        id: 'boat_demo_${prefix}_$n',
        name: 'Thuyền Demo $prefix-$n',
        description: 'Thuyền demo để test owner/admin, phù hợp cho nhóm từ $cap khách.',
        capacity: cap,
        hourlyPrice: price.toDouble(),
        rating: 4.2 + ((i % 7) * 0.1),
        ownerEmail: ownerEmail,
        gallery: <String>[
          images[i % images.length],
          images[(i + 1) % images.length],
          images[(i + 2) % images.length],
        ],
        blockedDateYmd: <String>{},
      );
    });
  }
}
