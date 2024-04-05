import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapsPage extends StatefulWidget {
  const GoogleMapsPage({super.key});

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

final locationController = Location();
const home = LatLng(13.333089159437348, 80.19066875975268);
const ssBriyani = LatLng(13.332753785473022, 80.19427901308666);

LatLng? currentPosition;

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
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // fetcching the location after rendering the UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchLocationUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition:
                  const CameraPosition(target: home, zoom: 13),
              markers: {
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentPosition!,
                ),
                const Marker(
                    markerId: MarkerId('sourceLoaction'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: home),
                const Marker(
                    markerId: MarkerId('destinationLoaction'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: ssBriyani)
              },
            ),
    );
  }
}
