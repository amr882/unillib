import 'package:flutter/material.dart';
import 'package:unilib/feature/login/logic/login_validator.dart';

import 'package:unilib/feature/login/repo/login_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController({LoginRepository? repo}) : _repo = repo ?? LoginRepository();
  final LoginRepository _repo;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? validateEmail(String? v) => LoginValidator.validateEmail(v);
  String? validatePassword(String? v) => LoginValidator.validatePassword(v);

  Future<bool> login(BuildContext context) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.loginUser(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }
}
