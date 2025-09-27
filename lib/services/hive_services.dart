import 'package:hive_flutter/hive_flutter.dart';


class HiveServices {
  static late Box _box;

  static Future<void> initHive() async {
     await Hive.initFlutter();
    _box = await Hive.openBox('myBox');
  }

  Future<void> saveData(String key, dynamic value) async {
    await _box.put(key, value);
  }

   dynamic getData(String key) async {
    return _box.get(key);
  }

   Future<void> deleteData(String key) async {
    await _box.delete(key);
  }

   Future<void> clearBox() async {
    await _box.clear();
  }
}