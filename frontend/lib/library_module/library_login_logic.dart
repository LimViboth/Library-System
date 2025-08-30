import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'logged_user_model.dart';
import 'library_service.dart';

final FlutterSecureStorage _storage = FlutterSecureStorage();
const _key = "LibraryLogic";
final _defaultLoggedUser = LoggedUserModel(
  user: User(
    id: 0,
    name: "name",
    email: "email",
    emailVerifiedAt: "emailVerifiedAt",
    createdAt: "createdAt",
    updatedAt: "updatedAt",
  ),
  token: "",
);

class LibraryLoginLogic extends ChangeNotifier {
  LoggedUserModel _loggedUser = _defaultLoggedUser;
  LoggedUserModel get loggedUser => _loggedUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<LoggedUserModel> readLoggedUser() async {
    await Future.delayed(Duration(seconds: 1));
    String? value = await _storage.read(key: _key);

    if (value == null) {
      _loggedUser = _defaultLoggedUser;
    } else {
      try {
        _loggedUser = loggedUserModelFromJson(value);
      } catch (e) {
        _loggedUser = _defaultLoggedUser;
      }
    }
    notifyListeners();
    return _loggedUser;
  }

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await LibraryService.login(email, password);

      final userData = response['data']['user'];
      final token = response['data']['token'];

      final loggedUser = LoggedUserModel(
        user: User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerifiedAt: userData['email_verified_at'] ?? '',
          createdAt: userData['created_at'],
          updatedAt: userData['updated_at'],
        ),
        token: token,
      );

      await saveLoggedUser(loggedUser);
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerUser(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await LibraryService.register(name, email, password);

      final userData = response['data']['user'];
      final token = response['data']['token'];

      final loggedUser = LoggedUserModel(
        user: User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerifiedAt: userData['email_verified_at'] ?? '',
          createdAt: userData['created_at'],
          updatedAt: userData['updated_at'],
        ),
        token: token,
      );

      await saveLoggedUser(loggedUser);
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logoutUser() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_loggedUser.token.isNotEmpty) {
        await LibraryService.logout(_loggedUser.token);
      }
      await clearLoggedUser();
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      await clearLoggedUser();
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<void> forceLogout() async {
    await clearLoggedUser();
    await LibraryService.deleteToken();
    _loggedUser = _defaultLoggedUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future saveLoggedUser(LoggedUserModel user) async{
    _loggedUser = user;
    await _storage.write(key: _key, value: loggedUserModelToJson(user));
    notifyListeners();
  }

  Future clearLoggedUser() async{
    _loggedUser = _defaultLoggedUser;
    await _storage.delete(key: _key);
    notifyListeners();
  }
}
