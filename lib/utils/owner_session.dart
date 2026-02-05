class OwnerSession {
  static int? ownerId;

  static bool get isLoggedIn => ownerId != null;

  static void logout() {
    ownerId = null;
  }
}
