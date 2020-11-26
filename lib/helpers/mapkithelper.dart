import 'package:maps_toolkit/maps_toolkit.dart';

class MapKitHelper{

  static double getMarkerRotation(sourceLat,sourceLng,destLat,destLng){

    var rotation = SphericalUtil.computeHeading(
        LatLng(sourceLat,sourceLng),
        LatLng(destLat,destLng)
    );
    return rotation;

  }

}