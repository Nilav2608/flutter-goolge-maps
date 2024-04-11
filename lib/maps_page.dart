import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_app/constants.dart';
import 'package:maps_app/models/directions.model.dart';
import 'package:maps_app/repo/directions_repository.dart';
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

Marker? originMarker;
Marker? destinationMarker;

Map<PolylineId, Polyline> polyLines = {};

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  // ask permission to access the current location

  Future<void> cameraPosition(LatLng markerPosition) async {
    // create an variable to access the mapController from the onMapCreated: property
    //current map camera position
    CameraPosition mapCameraPosition =
        CameraPosition(target: markerPosition, zoom: 15);
    //animate the camera to the current location
    await mapController!
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
    // await fetchLocationUpdates();
    final coordinates = await MapRepository().getPolyLinePoints(
        apiKey: apiKey, sourceLocation: googlePlex, destLocation: applePark);
    generatePolylines(coordinates);
  }

  static const initialCameraPosition =
      CameraPosition(target: googlePlex, zoom: 13.5);

  GoogleMapController? mapController;

  Directions? info;

  @override
  void dispose() {
    super.dispose();
    mapController!.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Dio dioClient = Dio();
  void addMarker(LatLng pos) async {
    if (originMarker == null ||
        (originMarker != null && destinationMarker != null)) {
      //origin marker is not set OR origin and destination marker both are set
      setState(() {
        originMarker = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        destinationMarker = null;
        info = null;
      });
    } else {
      //Origin is already set
      //Set destination
      setState(() {
        destinationMarker = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);
      });
      final directions = await DirectionsRepository(dioClient)
          .getDirections(origin: originMarker!.position, destination: pos);

      setState(() {
        info = directions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        actions: [
          if (originMarker != null)
            TextButton(
                onPressed: () {
                  cameraPosition(originMarker!.position);
                },
                child: Text(
                  "ORIGIN",
                  style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                )),
          if (destinationMarker != null)
            TextButton(
                onPressed: () {
                  cameraPosition(destinationMarker!.position);
                },
                child: const Text(
                  "DEST",
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 33, 79, 243)),
                ))
        ],
      ),
      body:
          // currentPosition == null
          //     ? const Center(child: CircularProgressIndicator())
          //     :
          Stack(children: [
        GoogleMap(
          onLongPress: (LatLng position) => addMarker(position),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) =>
              mapController = controller,
          initialCameraPosition: initialCameraPosition,
          markers: {
            const Marker(
                markerId: MarkerId('sourceLoaction'),
                icon: BitmapDescriptor.defaultMarker,
                position: googlePlex),
            if (originMarker != null) originMarker!,
            if (destinationMarker != null) destinationMarker!,
          },
          polylines: {
            if (info != null)
              Polyline(
                  polylineId: const PolylineId('overView-polyLine'),
                  color: Colors.blue.shade400,
                  points: info!.polyinePoints!
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                  width: 6)
          },
        ),
        if (info != null)
          Positioned(
              top: 10,
              child: BottomCard(
                distance: info!.totalDistance ?? '',
                duration: info!.totalDuration ?? '',
              ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController!.animateCamera(
              // info != null
              // ? CameraUpdate.newLatLngBounds(info.bounds!, 100)
              // :
              CameraUpdate.newCameraPosition(initialCameraPosition));
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
