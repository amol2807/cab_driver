import 'dart:math';

import 'package:cab_driver/datamodels/directiondetails.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/helpers/requesthelper.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class HelperMethods{

   static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {
   String url =
'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';

      var response = await RequestHelper.getRequest(url);
      if (response == 'failed')
      {
        print("failed");
        return null;
      }
      DirectionDetails directionDetails=DirectionDetails();
      directionDetails.durationText=response['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue=response['routes'][0]['legs'][0]['duration']['value'];
      directionDetails.distanceText=response['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue=response['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.encodedPoints=response['routes'][0]['overview_polyline']['points'];
      return directionDetails;
    }
    static int estimateFares(DirectionDetails details)
    {
      //per km = 0.3$
      //per min = 0.2$
      //base fare = 3$
      double baseFare = 3;
      double distanceFare = (details.distanceValue/1000)*0.3;
      print('Distant to Pune is ${details.distanceValue}');
      print('TIME to Pune is ${details.durationValue}');
      double timeFare = (details.durationValue/60)*0.2;
      double totalFare = baseFare + distanceFare + timeFare;
      print('BaseFare is ${baseFare}');
      print(timeFare);
      print(distanceFare);
      print(totalFare);

      return totalFare.truncate();

    }
    static double generateRandomNumber(int max)
    {
      var randomGenerator=Random();
      int radInt=randomGenerator.nextInt(max);

      return radInt.toDouble();
    }

    static void disableHomeTabLocationUpdates()
    {
      homeTabPositionStream.pause();
      Geofire.removeLocation(currentFireBaseUser.uid);
    }
   static void enableHomeTabLocationUpdates()
   {
     homeTabPositionStream.resume();
     Geofire.setLocation(currentFireBaseUser.uid, currentPosition.latitude, currentPosition.longitude);
   }



}