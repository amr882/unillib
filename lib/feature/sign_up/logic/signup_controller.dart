import 'package:flutter/material.dart';
import 'package:unilib/feature/sign_up/repo/auth_repository.dart';
import 'signup_validators.dart';

class SignupController extends ChangeNotifier {
  SignupController({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  final AuthRepository _repo;
  int _step = 0;
  int get step => _step;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final formKeyStep0 = GlobalKey<FormState>();
  final formKeyStep1 = GlobalKey<FormState>();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final studentIdCtrl = TextEditingController();
  final facultyCtrl = TextEditingController();

  static const List<String> academicYears = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Masters',
    'PhD',
  ];
  String selectedYear = academicYears[0];

  void setYear(String year) {
    selectedYear = year;
    notifyListeners();
  }

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  String? validateFirstName(String? v) => SignupValidators.validateFirstName(v);
  String? validateLastName(String? v) => SignupValidators.validateLastName(v);
  String? validateStudentId(String? v) => SignupValidators.validateStudentId(v);
  String? validateFaculty(String? v) => SignupValidators.validateFaculty(v);
  String? validateEmail(String? v) => SignupValidators.validateEmail(v);
  String? validatePassword(String? v) => SignupValidators.validatePassword(v);
  String? validateConfirmPassword(String? v) =>
      SignupValidators.validateConfirmPassword(v, passwordCtrl.text);

  bool nextStep() {
    final key = _step == 0 ? formKeyStep0 : formKeyStep1;
    if (!key.currentState!.validate()) return false;
    _step++;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void prevStep() {
    if (_step > 0) {
      _step--;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> createAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.registerUser(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text,
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        studentId: studentIdCtrl.text.trim(),
        faculty: facultyCtrl.text.trim(),
        academicYear: selectedYear,
      );
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      _errorMessage = _repo.mapError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    studentIdCtrl.dispose();
    facultyCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }
}
