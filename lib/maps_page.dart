import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_app/constants.dart';
import 'package:maps_app/repo/map_repo.dart';
import 'package:maps_app/widgets/bottom_card.dart';
import 'package:http/http.dart' as http;

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({super.key});

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

final locationController = Location();
const googlePlex = LatLng(37.422131, -122.084801);
const applePark = LatLng(37.3346, -122.0090);

LatLng? currentPosition;

String? currentDistance;
String? currentDuration;

final Completer<GoogleMapController> mapController =
    Completer<GoogleMapController>();

Map<PolylineId, Polyline> polyLines = {};

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  //ask permission to access the current location
  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus status;
    // check the location service of the device is enabled
    serviceEnabled = await locationController.serviceEnabled();

    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    status = await locationController.hasPermission();
    if (status == PermissionStatus.denied) {
      status = await locationController.requestPermission();
      if (status != PermissionStatus.granted) {
        return;
      }
    }
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          cameraPosition(currentPosition!);
        });
      }
    });
  }

  Future<void> cameraPosition(LatLng markerPosition) async {
    // create an variable to access the mapController from the onMapCreated: property
    final GoogleMapController controller = await mapController.future;
    //current map camera position
    CameraPosition mapCameraPosition =
        CameraPosition(target: markerPosition, zoom: 13);
    //animate the camera to the current location
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(mapCameraPosition));
  }

  void generatePolylines(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue.shade400,
        points: polylineCoordinates,
        width: 6);
    setState(() {
      polyLines[id] = polyline;
    });
  }

  Future initializeMap() async {
    await fetchLocationUpdates();
    final coordinates = await MapRepository().getPolyLinePoints(
        apiKey: apiKey, sourceLocation: googlePlex, destLocation: applePark);
    generatePolylines(coordinates);
    await fetchDistanceAndDuration();
  }

  Future<void> fetchDistanceAndDuration() async {
    final String origin =
        '${currentPosition!.latitude},${currentPosition!.longitude}';
    final String destination = '${applePark.latitude},${applePark.longitude}';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        currentDistance =
            decoded['routes'][0]['legs'][0]['distance']['text'] as String;
        currentDuration =
            decoded['routes'][0]['legs'][0]['duration']['text'] as String;
      });
    } else {
      throw Exception('Failed to fetch distance and duration');
    }
  }

  @override
  void initState() {
    super.initState();
    // fetching the location after rendering the UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchLocationUpdates().then((_) => initializeMap());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              GoogleMap(
                onMapCreated: (GoogleMapController controller) =>
                    mapController.complete(controller),
                initialCameraPosition:
                    const CameraPosition(target: googlePlex, zoom: 13),
                markers: {
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: currentPosition!,
                  ),
                  const Marker(
                      markerId: MarkerId('sourceLoaction'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: googlePlex),
                  const Marker(
                      markerId: MarkerId('destinationLoaction'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: applePark)
                },
                polylines: Set<Polyline>.of(polyLines.values),
              ),
               Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: BottomCard(
                    distance: currentDistance??'',
                    duration: currentDuration??'',
                  ))
            ]),
    );
  }
}
