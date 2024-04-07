
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRepository{
  // this returns a list of polyLine Coordinates
  Future<List<LatLng>> getPolyLinePoints({required String apiKey, required LatLng sourceLocation, required LatLng destLocation}) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polyLinePoints = PolylinePoints();
    // to get directional routes
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destLocation.latitude, destLocation.longitude),
        //travel model to define what type of travel mode we are driving
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      return polylineCoordinates;
    } else {
      print(result.errorMessage);
      return [];
    }
  }
}