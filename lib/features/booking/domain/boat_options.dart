class BoatOption {
  const BoatOption({required this.id, required this.name});

  final String id;
  final String name;
}

/// Danh sách thuyền demo — `boat_1` / `boat_2` trùng với marker trên [MapScreen].
const List<BoatOption> kBoatOptions = [
  BoatOption(id: 'boat_1', name: 'Tiên Sa Cruise'),
  BoatOption(id: 'boat_2', name: 'Rồng Vàng'),
  BoatOption(id: 'boat_han_01', name: 'Thuyền Hàn River 01'),
  BoatOption(id: 'boat_han_02', name: 'Thuyền Hàn River 02'),
  BoatOption(id: 'boat_sunset', name: 'Thuyền Hoàng hôn'),
  BoatOption(id: 'boat_lux', name: 'Thuyền Luxury Cruise'),
];
