import 'package:shared_preferences/shared_preferences.dart';

class AppAuthProvider {
  static String currentUser = '';

  static Future<String?> getCurrentUser() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(currentUser);
  }

  static setCurrentUser(String user) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString(currentUser, user);
  }

  static Future<bool> getLoginStatus() async {
    bool loggedIn;
    if (await AppAuthProvider.getCurrentUser() == null ||
        await AppAuthProvider.getCurrentUser() == '') {
      loggedIn = false;
    } else {
      loggedIn = true;
    }
    return loggedIn;
  }
}
