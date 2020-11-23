import 'dart:async';

import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/widgets/AvailabilityButton.dart';
import 'package:cab_driver/widgets/confirmsheet.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../globalvariables.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;

  DatabaseReference tripRequestRef;

  Position currentPosition;

  var geolocator = Geolocator();
  var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  String availabilityTitle = 'GO ONLINE';
  Color availabilityColor = BrandColors.colorOrange;

  bool isAvailable = false;

  void getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    //CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 14.0);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

    //  String address = await HelperMethods.findCoordinateAddress(position, context);
    //  print(address);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
            padding: EdgeInsets.only(top: 135),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              getCurrentPosition();
            },
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: googlePlex,
            myLocationEnabled: true),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (BuildContext context) => ConfirmSheet(
                      title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                      subTitle: (!isAvailable)
                          ? 'You are about to become available'
                          : 'You will stop receiving new trip requests',
                      onPressed: () {
                        if (!isAvailable) {
                          goOnline();
                          getLocationUpdates();
                          Navigator.pop(context); // Hide the bottom sheet

                          setState(() {
                            isAvailable = true;
                            availabilityTitle = 'GO OFFLINE';
                            availabilityColor = BrandColors.colorGreen;
                          });
                        } else {
                          goOffline();
                          Navigator.pop(context);

                          setState(() {
                            isAvailable = false;
                            availabilityTitle = 'GO ONLINE';
                            availabilityColor = BrandColors.colorOrange;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void goOnline() {
    Geofire.initialize('driversAvailable');
    Geofire.setLocation(currentFireBaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);

    tripRequestRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFireBaseUser.uid}/newtrip');
    tripRequestRef.set('waiting');

    tripRequestRef.onValue.listen((event) {});
  }

  void getLocationUpdates() {
    homeTabPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 4)
        .listen((Position position) {
      currentPosition = position;

      if (isAvailable) {
        Geofire.setLocation(currentFireBaseUser.uid, currentPosition.latitude,
            currentPosition.longitude);
      }
      LatLng pos = LatLng(position.latitude, position.longitude);
      //CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 14.0);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  void goOffline() {
    Geofire.removeLocation(currentFireBaseUser.uid);
    tripRequestRef.onDisconnect();
    tripRequestRef.remove();
    tripRequestRef = null;
  }
}
