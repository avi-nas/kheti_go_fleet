import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HandleUserData{
  static FirebaseAuth firebaseAuthInstance = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static Future<bool> isNewUser(String? number)async{
    bool isNew = true;
    await firebaseFirestore.collection('FleetAdmin').where('phoneNumber',isEqualTo:number).get().then((value){
      if(value.size ==0){
        isNew = true;
      }
      else{
        isNew = false;
      }
    });
    return isNew;
  }
  static Future<void> createNewUser(var json)async {
    firebaseFirestore.collection('FleetAdmin').doc(firebaseAuthInstance.currentUser?.uid).set(json);
  }
}