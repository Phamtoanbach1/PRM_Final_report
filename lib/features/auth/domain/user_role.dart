enum UserRole {
  user,
  shopOwner,
  admin;

  String get storageValue {
    switch (this) {
      case UserRole.user:
        return 'user';
      case UserRole.shopOwner:
        return 'shop_owner';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get labelVi {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.shopOwner:
        return 'Shop Owner';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static UserRole fromStorage(String? value) {
    switch (value) {
      case 'shop_owner':
        return UserRole.shopOwner;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }
}
