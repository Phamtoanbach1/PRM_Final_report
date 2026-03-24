import 'package:flutter/foundation.dart';

import '../data/promo_repository.dart';
import '../domain/booking_pricing.dart';
import '../domain/owner_promo_code.dart';

class PromoProvider extends ChangeNotifier {
  PromoProvider({PromoRepository? repository}) : _repository = repository ?? PromoRepository() {
    load();
  }

  final PromoRepository _repository;
  List<OwnerPromoCode> _promos = <OwnerPromoCode>[];

  List<OwnerPromoCode> get promos => List.unmodifiable(_promos);

  Future<void> load() async {
    _promos = await _repository.loadAll();
    if (_promos.isEmpty) {
      _promos = _seedPromos();
      await _repository.saveAll(_promos);
    }
    notifyListeners();
  }

  List<OwnerPromoCode> promosForOwner(String? ownerEmail) {
    final normalized = (ownerEmail ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return List<OwnerPromoCode>.from(_promos);
    return _promos.where((e) => e.ownerEmail.toLowerCase() == normalized).toList();
  }

  Future<void> addPromo({
    required String ownerEmail,
    required String code,
    required double discountPercent,
    int? usageLimitTotal,
    DateTime? expiresAt,
    int? minHours,
    List<String> boatScopeIds = const <String>[],
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) throw Exception('Mã giảm giá không được để trống');
    if (discountPercent <= 0 || discountPercent > 0.9) throw Exception('Giảm giá phải từ 1% đến 90%');
    if (_promos.any((e) => e.code == normalizedCode)) throw Exception('Mã giảm giá đã tồn tại');
    final promo = OwnerPromoCode(
      id: 'promo_${DateTime.now().microsecondsSinceEpoch}',
      ownerEmail: ownerEmail.trim(),
      code: normalizedCode,
      discountPercent: discountPercent,
      usageLimitTotal: usageLimitTotal,
      expiresAt: expiresAt,
      minHours: minHours,
      boatScopeIds: boatScopeIds,
    );
    _promos = <OwnerPromoCode>[promo, ..._promos];
    await _repository.saveAll(_promos);
    notifyListeners();
  }

  Future<void> deletePromo(String id, {required String actorEmail, required bool isAdmin}) async {
    OwnerPromoCode? target;
    for (final item in _promos) {
      if (item.id == id) {
        target = item;
        break;
      }
    }
    if (target == null) return;
    final canDelete = isAdmin || target.ownerEmail.toLowerCase() == actorEmail.toLowerCase();
    if (!canDelete) throw Exception('Không có quyền xóa mã này');
    _promos.removeWhere((e) => e.id == id);
    await _repository.saveAll(_promos);
    notifyListeners();
  }

  Future<void> updatePromo({
    required String id,
    required String actorEmail,
    required bool isAdmin,
    required String code,
    required double discountPercent,
    int? usageLimitTotal,
    DateTime? expiresAt,
    int? minHours,
    List<String> boatScopeIds = const <String>[],
    bool isActive = true,
  }) async {
    final idx = _promos.indexWhere((e) => e.id == id);
    if (idx < 0) throw Exception('Không tìm thấy mã');
    final current = _promos[idx];
    final canEdit = isAdmin || current.ownerEmail.toLowerCase() == actorEmail.toLowerCase();
    if (!canEdit) throw Exception('Không có quyền sửa mã này');

    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) throw Exception('Mã giảm giá không được để trống');
    if (discountPercent <= 0 || discountPercent > 0.9) throw Exception('Giảm giá phải từ 1% đến 90%');
    final codeUsedByAnother = _promos.any((e) => e.id != id && e.code == normalizedCode);
    if (codeUsedByAnother) throw Exception('Mã giảm giá đã tồn tại');

    _promos[idx] = current.copyWith(
      code: normalizedCode,
      discountPercent: discountPercent,
      usageLimitTotal: usageLimitTotal,
      expiresAt: expiresAt,
      minHours: minHours,
      boatScopeIds: boatScopeIds,
      isActive: isActive,
    );
    await _repository.saveAll(_promos);
    notifyListeners();
  }

  ({bool ok, String? reason, OwnerPromoCode? promo}) validatePromo({
    required String code,
    required String boatId,
    required String boatOwnerEmail,
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      return (ok: false, reason: 'Mã giảm giá trống', promo: null);
    }
    OwnerPromoCode? promo;
    for (final item in _promos) {
      if (item.code == normalizedCode) {
        promo = item;
        break;
      }
    }
    if (promo == null || !promo.isActive) {
      return (ok: false, reason: 'Mã giảm giá không hợp lệ', promo: null);
    }
    if (promo.ownerEmail.toLowerCase() != boatOwnerEmail.toLowerCase()) {
      return (ok: false, reason: 'Mã này không áp dụng cho thuyền đã chọn', promo: null);
    }
    if (promo.expiresAt != null && promo.expiresAt!.isBefore(DateTime.now())) {
      return (ok: false, reason: 'Mã đã hết hạn', promo: null);
    }
    if (promo.usageLimitTotal != null && promo.usedCount >= promo.usageLimitTotal!) {
      return (ok: false, reason: 'Mã đã hết lượt sử dụng', promo: null);
    }
    if (promo.boatScopeIds.isNotEmpty && !promo.boatScopeIds.contains(boatId)) {
      return (ok: false, reason: 'Mã không áp dụng cho thuyền này', promo: null);
    }
    final hours = BookingPricing.billableHours(start, end);
    if (promo.minHours != null && hours < promo.minHours!) {
      return (ok: false, reason: 'Mã yêu cầu tối thiểu ${promo.minHours} giờ', promo: null);
    }
    return (ok: true, reason: null, promo: promo);
  }

  Future<void> markPromoUsed(String id) async {
    final idx = _promos.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    _promos[idx] = _promos[idx].copyWith(usedCount: _promos[idx].usedCount + 1);
    await _repository.saveAll(_promos);
    notifyListeners();
  }

  List<OwnerPromoCode> _seedPromos() {
    final now = DateTime.now();
    return <OwnerPromoCode>[
      OwnerPromoCode(
        id: 'promo_seed_owner_1',
        ownerEmail: 'owner@hancruise.local',
        code: 'OWNER10',
        discountPercent: 0.10,
        usageLimitTotal: 100,
        usedCount: 7,
        expiresAt: now.add(const Duration(days: 90)),
      ),
      OwnerPromoCode(
        id: 'promo_seed_owner_2',
        ownerEmail: 'owner@hancruise.local',
        code: 'SUNSET15',
        discountPercent: 0.15,
        usageLimitTotal: 50,
        usedCount: 4,
        minHours: 3,
        expiresAt: now.add(const Duration(days: 60)),
      ),
      OwnerPromoCode(
        id: 'promo_seed_owner2_1',
        ownerEmail: 'owner2@hancruise.local',
        code: 'LUX20',
        discountPercent: 0.20,
        usageLimitTotal: 40,
        usedCount: 9,
        minHours: 2,
        expiresAt: now.add(const Duration(days: 45)),
      ),
      OwnerPromoCode(
        id: 'promo_seed_owner2_2',
        ownerEmail: 'owner2@hancruise.local',
        code: 'VIPNIGHT',
        discountPercent: 0.12,
        usageLimitTotal: 80,
        usedCount: 11,
        expiresAt: now.add(const Duration(days: 120)),
      ),
    ];
  }
}
