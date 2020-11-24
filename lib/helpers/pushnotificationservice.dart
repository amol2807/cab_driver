import 'package:cab_driver/globalvariables.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize() async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Future<String> getToken() async{

    String token = await fcm.getToken();
    print('token is {$token)');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('drivers/${currentFireBaseUser.uid}/token');
    tokenRef.set(token);
    
    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');



  }









}
