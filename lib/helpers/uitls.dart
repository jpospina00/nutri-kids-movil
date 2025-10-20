import 'package:nutri_kids_movil/models/user_model.dart';
import 'package:nutri_kids_movil/services/hive_services.dart';

class Utils {
  Future<User?> getUserHive() async {
    HiveServices hiveServices = HiveServices();
    Map<String, dynamic> userData = await hiveServices.getData('user');
    print('User Data: $userData');

    return User.fromJson(userData);
  }
}
