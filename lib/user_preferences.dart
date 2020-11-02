import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._ctor();
  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._ctor();

  SharedPreferences _prefs;

  var listOne = [];
  var listTwo = [];
  DateTime date;
  String id;

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  get data {
    return _prefs.getString('data') ?? '';
  }

  set data(String value) {
    _prefs.setString('data', value);
    // listOne.add(data);
    // _prefs.setStringList('list', listOne);
  }

  // Future<Null> addString() async {
  //   final SharedPreferences prefs = _prefs;
  //   listOne.add(data);
  //   prefs.setStringList('list', listOne);
  // }

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
    await _prefs.remove(data);
  }

  clearItems() async {
    final SharedPreferences prefs = _prefs;
    prefs.clear();
  }

  static const amountField = 'amount'; // will be in ml
  static const dateField = 'date';

  UserPreferences.temp() {
    this.date = DateTime.now();
  }

  UserPreferences.fromDb(Map<String, dynamic> json, String id) {
    this.id = id;
    this.date = json[dateField].toDate();
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     dateField: Timestamp.fromDate(this.date),
  //   };
  // }

  @override
  String toString() {
    return 'date: $date';
  }
}
