import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService{
  //////////-----------Store bool --> SharedPreferences----------------
  static Future saveBoolToSharedPreferences(String key, bool value) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool(key, value);
  }
}