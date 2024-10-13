class UserState {
  static final UserState _instance = UserState._internal();
  factory UserState() => _instance;

  UserState._internal();

  String? username;
  bool isAdmin = false;

  void login(String username, bool isAdmin) {
    this.username = username;
    this.isAdmin = isAdmin;
  }

  void logout() {
    this.username = null;
    this.isAdmin = false;
  }

  bool get isLoggedIn => username != null;
}

