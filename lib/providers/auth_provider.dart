import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    final loggedIn = await _storage.isLoggedIn();
    if (loggedIn) {
      _user = await _storage.getUser();
      _isLoggedIn = _user != null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final savedUser = await _storage.getUser();
    if (savedUser != null &&
        savedUser.email == email &&
        savedUser.password == password) {
      _user = savedUser;
      _isLoggedIn = true;
      await _storage.saveUser(savedUser);
      notifyListeners();
      return true;
    }
    // For demo, allow any login with stored or new user
    if (savedUser != null && savedUser.email == email) {
      return false; // Wrong password
    }
    // No user found at all — let them in as demo
    _user = savedUser ??
        UserModel(
          id: const Uuid().v4(),
          name: 'Nikhil',
          email: email,
          password: password,
          accountType: 'home',
          accountTypeLocked: false,
        );
    _isLoggedIn = true;
    await _storage.saveUser(_user!);
    notifyListeners();
    return true;
  }

  Future<bool> signup(String name, String email, String password) async {
    _user = UserModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      password: password,
      accountType: 'home',
      accountTypeLocked: false,
    );
    _isLoggedIn = true;
    await _storage.saveUser(_user!);
    notifyListeners();
    return true;
  }

  Future<void> setAccountType(String type) async {
    if (_user != null) {
      _user = _user!.copyWith(
        accountType: type,
        accountTypeLocked: true,
      );
      await _storage.saveUser(_user!);
      await _storage.saveAccountType(type);
      await _storage.setAccountLocked(true);
      notifyListeners();
    }
  }

  Future<void> changeAccountTypeViaChatbot(String type) async {
    if (_user != null) {
      _user = _user!.copyWith(
        accountType: type,
        accountTypeLocked: true,
      );
      await _storage.saveUser(_user!);
      await _storage.saveAccountType(type);
      notifyListeners();
    }
  }

  bool get isAccountTypeLocked => _user?.accountTypeLocked ?? false;
  String get accountType => _user?.accountType ?? 'home';

  Future<void> logout() async {
    _isLoggedIn = false;
    await _storage.logout();
    notifyListeners();
  }
}
