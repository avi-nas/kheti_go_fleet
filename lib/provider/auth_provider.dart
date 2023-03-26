import 'package:shared_preferences/shared_preferences.dart';

class AppAuthProvider{
  static String currentUser ='';

  static Future<String?> getCurrentUser()async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(currentUser);
  }

  static setCurrentUser(String user)async{
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString(currentUser, user);
  }
  static Future<bool> getLoginStatus()async{
    bool loggedIn;
    if(currentUser == 'user'){
      loggedIn = true;
    }else{
      loggedIn = false;
    }
    return loggedIn;
  }

}