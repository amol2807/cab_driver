//import 'dart:html' ;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cab_driver/datamodels/tripdetails.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/widgets/NotificationDialog.dart';
import 'package:cab_driver/widgets/progressdialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(context) async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideID(message),context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideID(message),context);
      },
      onResume: (Map<String, dynamic> message) async {
        fetchRideInfo(getRideID(message),context);
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

  String getRideID(Map<String, dynamic> message){
    String rideID=message['data']['ride_id'];
    return rideID;
  }

  void fetchRideInfo(String rideId,context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialogue(
        status: 'fetching details',
      ),
    );
    DatabaseReference rideRef=FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    rideRef.once().then((DataSnapshot snapshot){
      Navigator.pop(context);
      if(snapshot.value!=null)
        {
          assetsAudioPlayer.open(Audio('sounds/alert.mp3'));
          assetsAudioPlayer.play();

          double pickupLat=double.parse(snapshot.value['location']['latitude']);
          double pickupLong=double.parse(snapshot.value['location']['longitude']);
          String pickupAddress=snapshot.value['pickup_address'].toString();

          double destinationLat=double.parse(snapshot.value['destination']['latitude']);
          double destinationLong=double.parse(snapshot.value['destination']['longitude']);
          String destinationAddress=snapshot.value['destination_address'].toString();
          String paymentMethod=snapshot.value['payment_method'];

          TripDetails tripDetails=TripDetails();
          tripDetails.pickup=LatLng(pickupLat,pickupLong);
          tripDetails.destination=LatLng(destinationLat, destinationLong);
          tripDetails.pickupAddress=pickupAddress;
          tripDetails.destinationAddress=destinationAddress;
          tripDetails.rideID=rideId;
          tripDetails.paymentMethod=paymentMethod;

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context)=>NotificationDailog(tripDetails: tripDetails,),
          );
        }
    });
  }







}
