import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._ctor();
  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._ctor();

  SharedPreferences _prefs;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  get data {
    return _prefs.getString('data') ?? '';
  }

  set data(String value) {
    _prefs.setString('data', value);
  }

  // delete(String value) {
  //   _prefs.remove(value);
  // }

  // Future delete
  // async(String value) {
  //   _prefs.remove(value);
  //   // _prefs = await SharedPreferences.getInstance();
  //   // await prefs.clear();
  // }

  // SharedPreferences preferences = await SharedPreferences.getInstance();

  delete(String value) async {
    await _prefs.clear();
  }

  Future setJwtToken(String value) {
    return _prefs.setString('jwtToken', value);
  }
}
