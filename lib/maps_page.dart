import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_app/constants.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({super.key});

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

final locationController = Location();
const googlePlex = LatLng(37.4223, -122.8848);
const applePark = LatLng(37.3346, -122.0090);

LatLng? currentPosition;

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

  // this returns a list of polyLine Coordinates
  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polyLinePoints = PolylinePoints();
    // to get directional routes
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(googlePlex.latitude, googlePlex.longitude),
        PointLatLng(applePark.latitude, applePark.longitude),
        //travel model to define what type of travel mode we are driving
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    print(polylineCoordinates);
    return polylineCoordinates;
  }

  void generatePolylinesL(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("main");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue.shade400,
        points: polylineCoordinates,
        width: 6);
    setState(() {
      polyLines[id] = polyline;
    });
  }

  @override
  void initState() {
    super.initState();
    // fetching the location after rendering the UI
    WidgetsBinding.instance.addPostFrameCallback((_)  {
       fetchLocationUpdates().then((_) => getPolyLinePoints().then(
              (coordinates) =>
                  print(coordinates)) // generatePolylinesL(coordinates))
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  mapController.complete(controller),
              initialCameraPosition:
                  const CameraPosition(target: googlePlex, zoom: 13),
              markers: {
                const Marker(
                    markerId: MarkerId('sourceLoaction'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: googlePlex),
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentPosition!,
                ),
                const Marker(
                    markerId: MarkerId('destinationLoaction'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: applePark)
              },
            ),
    );
  }
}
