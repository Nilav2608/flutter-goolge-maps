import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_app/constants.dart';
import 'package:maps_app/models/directions.model.dart';

class DirectionsRepository {
  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/directions/json?";

  final Dio dio;

  DirectionsRepository(this.dio);

  Future<Directions?> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    final response = await dio.get(baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': apiKey
    });
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
