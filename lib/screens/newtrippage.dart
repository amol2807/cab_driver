import 'dart:async';

import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/datamodels/tripdetails.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/helpers/helpermethods.dart';
import 'package:cab_driver/helpers/mapkithelper.dart';
import 'package:cab_driver/widgets/TaxiButton.dart';
import 'package:cab_driver/widgets/collectPaymentDialog.dart';
import 'package:cab_driver/widgets/progressdialogue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;

  NewTripPage({this.tripDetails});

  static const String id = 'newtrippage';

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController rideMapController;
  double mapPaddingBottom = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polylines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.bestForNavigation);

  BitmapDescriptor movingMarkerIcon;

  Position myPosition;

  String status='accepted';

  String durationString='';

  bool isRequestingDirection=false;

  String buttonTitle='ARRIVED';
  Color buttonColor=BrandColors.colorGreen;

  Timer timer;

  int durationCounter=0;

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'images/car_android.png'
              /*(Platform.isIos)
            ?'images/car_ios.png'
            :'images/car_android.png'*/
              )
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptTrip();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingBottom),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            trafficEnabled: true,
            mapToolbarEnabled: true,
            compassEnabled: true,
            circles: _circles,
            polylines: _polylines,
            markers: _markers,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPaddingBottom = 260;
              });

               var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
               var pickupLatLng = widget.tripDetails.pickup;

               await getDirection(currentLatLng, pickupLatLng);

               getLocationUpdates();
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 0.5,
                      blurRadius: 15,
                      offset: Offset(0.7, 0.7),
                    ),
                  ]),
              height: 255,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      durationString,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Brand-Bold',
                        color: BrandColors.colorAccentPurple,
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Amol Gandhi',
                          style:
                              TextStyle(fontFamily: 'Brand-Bold', fontSize: 22),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(Icons.call),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/pickicon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'ABCD NY, Aurangabad (Pickup Address)',
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Image.asset(
                          'images/desticon.png',
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'WXYZ AB, Pune (Destination Address)',
                              style: TextStyle(fontSize: 17),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TaxiButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPressed: ()async {
                        if(status=='accepted')
                          {
                            status='arrived';
                            rideRef.child('status').set('arrived');

                            setState(() {
                              buttonColor=BrandColors.colorAccentPurple;
                              buttonTitle='Start Trip';
                            });
                            HelperMethods.showProgressDialog(context);
                            await getDirection(widget.tripDetails.pickup, widget.tripDetails.destination);
                            Navigator.pop(context);

                          }
                        else if(status=='arrived')
                          {
                            status='ontrip';
                            rideRef.child('status').set('ontrip');

                            setState(() {
                              buttonColor=Colors.red[800];
                              buttonTitle='END TRIP';
                            });
                            startTimer();
                          }
                        else if(status=='ontrip'){
                          endTrip();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getDirection(LatLng pickLatLng, LatLng destinationLatLng) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialogue(
              status: "Please Wait",
            ));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);
    print('AMOL PI ${pickLatLng.latitude}');
    print(pickLatLng.longitude);
    print(destinationLatLng.latitude);
    print(destinationLatLng.longitude);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      //loop through all PointLatLng points and convert them to a list of LatLng, required by the Polyline

      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    //make polyline to fit into the map
    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }
    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      // infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      // infoWindow:
      //InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  void acceptTrip() {
    String rideId = widget.tripDetails.rideID;

    rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/${rideId}/');

    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    // rideRef.child('email').set('accepted');
    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);
    rideRef
        .child('car_details')
        .set('${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}');

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString()
    };
    rideRef.child('driver_location').set(locationMap);
  }

  void getLocationUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .listen((Position position) {
      myPosition = position;
      currentPosition = position;

      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, position.latitude, position.longitude);

      Marker movingMarker = Marker(
          markerId: MarkerId('moving'),
          position: LatLng(position.latitude, position.longitude),
          icon: movingMarkerIcon,
          rotation: rotation,
          // for head
          infoWindow: InfoWindow(title: 'Current Location'));

      setState(() {
        CameraPosition cp = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 10);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMarker);
      });

      oldPosition = LatLng(position.latitude, position.longitude);
      updateTripDetails();

      Map locationMap={
        'latitude':myPosition.latitude.toString(),
        'longitude':myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);
    });
  }

  void updateTripDetails ()async
  {

    if(!isRequestingDirection){
      isRequestingDirection=true;

      if(myPosition==null){
        return;
      }
      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      LatLng destinationLatLng;
      if(status=='accepted')
      {
        destinationLatLng=widget.tripDetails.pickup;
      }
      else
      {
        destinationLatLng=widget.tripDetails.destination;
      }
      var directionDetails=await HelperMethods.getDirectionDetails(positionLatLng, destinationLatLng);

      if(directionDetails!=null)
      {
        setState(() {
          durationString=directionDetails.durationText;
        });
      }
      isRequestingDirection=false;
    }
  }

  void startTimer(){
    const interval=Duration(seconds: 1);
    timer=Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip()async{
    timer.cancel();
    HelperMethods.showProgressDialog(context);
    var currentLatLng=LatLng(myPosition.latitude, myPosition.longitude);
    var directionDetails=await HelperMethods.getDirectionDetails(widget.tripDetails.pickup, currentLatLng);
    Navigator.pop(context);
    int fares=HelperMethods.estimateFares(directionDetails, durationCounter);
    rideRef.child('fares').set(fares.toString());
    rideRef.child('status').set('ended');
    ridePositionStream.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:(BuildContext context)=>CollectPayment(
        paymentMethod: widget.tripDetails.paymentMethod,
        fares: fares,
      )
    );
    topUpEarnings(fares);
  }

  void topUpEarnings(int fares){
    DatabaseReference earningsRef=FirebaseDatabase.instance.reference().child('drivers/${currentFireBaseUser.uid}/earnings');
    earningsRef.once().then((DataSnapshot snapshot){
      if(snapshot.value!=null){
        double oldEarnings=double.parse(snapshot.value.toString());
        double adjustedFares=(fares.toDouble()*0.85)+oldEarnings;
        earningsRef.set(adjustedFares.toStringAsFixed(2));
      }
      else
        {
          double adjustedFares=(fares.toDouble()*0.85);
          earningsRef.set(adjustedFares.toStringAsFixed(2));
        }
    });
  }
}
