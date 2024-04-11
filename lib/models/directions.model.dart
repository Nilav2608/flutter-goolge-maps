import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Directions {
  final LatLngBounds? bounds;
  final List<PointLatLng>? polyinePoints;
  final String? totalDistance;
  final String? totalDuration;

  Directions(
      {required this.bounds,
      required this.polyinePoints,
      required this.totalDistance,
      required this.totalDuration});

  factory Directions.fromMap(Map<String, dynamic> map) {
  //   if (map['routes'] == null || (map['routes'] as List).isEmpty) {
  //   // Handle case where routes list is empty or null
  //   return Directions.em;
  // }

    final data = Map<String, dynamic>.from(map['routes'][0]);

    //Bounds
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];

    final bounds = LatLngBounds(
        southwest: LatLng(southwest['lat'], southwest['lng']),
        northeast: LatLng(northeast['lat'], northeast['lng']));

    String distance = '';
    String duration = '';

    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    return Directions(
        bounds: bounds,
        polyinePoints: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration);
  }
}
