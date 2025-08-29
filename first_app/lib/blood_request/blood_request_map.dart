import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class BloodRequestMap extends StatefulWidget {
  final String bloodGroup;
  final String units;
  final String contact;
  final DateTime requiredDate;
  final LatLng location;

  const BloodRequestMap({
    super.key,
    required this.bloodGroup,
    required this.units,
    required this.contact,
    required this.requiredDate,
    required this.location,
  });

  @override
  State<BloodRequestMap> createState() => _BloodRequestMapState();
}

class _BloodRequestMapState extends State<BloodRequestMap>
    with SingleTickerProviderStateMixin {
  LatLng? selectedLocation;
  String selectedAddress = 'Searching...';

  double currentRadius = 500; // in meters
  Timer? radiusTimer;

  List<LatLng> mockDonors = [];
  late AnimationController _pulseController;
  late Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.location;
    _resolveAddress(selectedLocation!);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _radiusAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAutoRadiusExpansion();
    _generateMockDonors(selectedLocation!);
  }

  void _resolveAddress(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          selectedAddress =
              '${placemark.street}, ${placemark.locality}, ${placemark.country}';
        });
      }
    } catch (e) {
      setState(() => selectedAddress = 'Address not found');
    }
  }

  void _startAutoRadiusExpansion() {
    radiusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        currentRadius += 500;
      });
    });
  }

  void _generateMockDonors(LatLng center) {
    final random = Random();
    const radiusInMeters = 1000;

    List<LatLng> newDonors = List.generate(5, (_) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * radiusInMeters;
      final dx = distance * cos(angle) / 111320;
      final dy =
          distance * sin(angle) / (111320 * cos(center.latitude * pi / 180));
      return LatLng(center.latitude + dy, center.longitude + dx);
    });

    setState(() {
      mockDonors = newDonors;
    });
  }

  @override
  void dispose() {
    radiusTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = currentRadius * _radiusAnimation.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: selectedLocation,
              zoom: 14,
              onTap: (tapPosition, latLng) {
                setState(() {
                  selectedLocation = latLng;
                  _resolveAddress(latLng);
                  _generateMockDonors(latLng); // regenerate donors each time
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYWRpbDQyMCIsImEiOiJjbWRrN3dhb2wwdXRnMmxvZ2dhNmY2Nzc3In0.yrzJJ09yyfdT4Zg4Y_CJhQ',
                additionalOptions: {
                  'accessToken':
                      'pk.eyJ1IjoiYWRpbDQyMCIsImEiOiJjbWRrN3dhb2wwdXRnMmxvZ2dhNmY2Nzc3In0.yrzJJ09yyfdT4Zg4Y_CJhQ',
                },
                userAgentPackageName: 'com.example.lifedrop',
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  return CircleLayer(
                    circles: [
                      if (selectedLocation != null)
                        CircleMarker(
                          point: selectedLocation!,
                          color: Colors.red.withOpacity(0.2),
                          borderStrokeWidth: 2,
                          borderColor: Colors.red,
                          useRadiusInMeter: true,
                          radius: effectiveRadius,
                        ),
                    ],
                  );
                },
              ),
              MarkerLayer(
                markers: [
                  if (selectedLocation != null)
                    Marker(
                      point: selectedLocation!,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 45),
                    ),
                  ...mockDonors
                      .where((donor) =>
                          Distance().as(LengthUnit.Meter, selectedLocation!, donor) <
                          effectiveRadius)
                      .map(
                        (donor) => Marker(
                          point: donor,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.bloodtype,
                              color: Colors.purple, size: 35),
                        ),
                      ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                selectedAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedLocation != null) {
            Navigator.pop(context, selectedLocation);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a location.')),
            );
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
