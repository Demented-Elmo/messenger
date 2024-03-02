import 'chat.dart';
import 'dart:async';
import 'variables.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class User extends StatefulWidget {
  const User({super.key});
  @override
  State<User> createState() {return _UserState();}}

class _UserState extends State<User> {

  double radius = 50;

  Future<void> _getLocation() async {
    LocationData locationData = await location.getLocation();
    setState(() {
      currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

  Future<void> _goToLocation() async {
    if (currentLocation.latitude == 0.0 && currentLocation.longitude == 0.0) {await _getLocation();}
    final GoogleMapController controller = await mapsController.future;
    
    final newCameraPosition = CameraPosition(
      target: currentLocation,
      zoom: 17.0,
      tilt: 45.0,);

    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    
    circles.clear();
    const circleId = CircleId('userlocation_circle');
    var circle = Circle(
      circleId: circleId,
      center: currentLocation,
      radius: radius,
      fillColor: Colors.blue.withOpacity(0.3),
      strokeColor: Colors.blue,
      strokeWidth: 3,
    );

    circles.add(circle);



    markers.clear();
    const MarkerId markerId = MarkerId('userlocation_marker');
    final Marker marker = Marker(
      markerId: markerId,
      position: currentLocation,
      icon: BitmapDescriptor.defaultMarker,
      onTap: _goToLocation,
    );
    markers.add(marker);
  }
  void updateRadius(double newRadius) {
      setState(() {
        radius = newRadius;
      });
      _goToLocation();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: themeColor, toolbarHeight: 5),
      backgroundColor: Colors.black,
      body: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        height: MediaQuery.of(context).size.height,
        color: bg,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(border: Border.all(color: themeColor, width: 4), borderRadius: BorderRadius.circular(13)),
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
                        child: GoogleMap(
                          mapType: MapType.hybrid,
                          initialCameraPosition: CameraPosition(
                            target: currentLocation,
                            zoom: 1,
                          ),
                          circles: Set.from(circles),
                          markers: Set.from(markers),
                          onMapCreated: (GoogleMapController controller) { 
                            mapsController.complete(controller);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 0),
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(border: Border.all(color: themeColor, width: 2), borderRadius: BorderRadius.circular(7)),
                    child:  TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 23),
                        iconColor: themeColor,
                        foregroundColor: themeColor,
                        surfaceTintColor: themeColorT1,
                      ),
                      onPressed: _goToLocation, 
                      child: const Text("My Location"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.48,
                    child: Slider(
                      value: radius,
                      min: 10,
                      max: 100,
                      divisions: 9,
                      label: radius.round().toString(),
                      onChanged: updateRadius,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 15),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width:340,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text("Light Mode"),
                              textColor: fg,
                              leading: Radio<SingingCharacter>(
                                value: SingingCharacter.light,
                                groupValue: character,
                                onChanged: (SingingCharacter? value){
                                  setState(() {
                                    fg = const Color.fromARGB(255, 29, 29, 29);
                                    bg = const Color.fromARGB(255, 255, 255, 255);
                                    hint = const Color.fromARGB(255, 95, 95, 95);
                                    character = value;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTileTheme(
                              child: ListTile(
                                title: const Text("Dark Mode"),
                                textColor: fg,
                                leading: Radio<SingingCharacter>(
                                  value: SingingCharacter.dark,
                                  groupValue: character,
                                  onChanged: (SingingCharacter? value){
                                    setState(() {
                                      fg = const Color.fromARGB(255, 255, 255, 255);
                                      bg = const Color.fromARGB(255, 37, 37, 37);
                                      hint = const Color.fromARGB(228, 255, 255, 255);
                                      character = value;
                                    });
                                  },
                                )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 20),
                  child: SizedBox(
                    width: 350,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: TextField(
                        controller: usrController,
                        autofocus: false,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(167, 104, 58, 183), width:1.5)),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple, width: 2.3)),
                            hintText: 'Set your username...',
                            hintStyle: TextStyle(color:hint)),
                        style: TextStyle(color: fg),
                        onSubmitted: (String nameRaw) {
                          sentOnce = false;
                          name = nameRaw.trim();
                          if(name.isEmpty == true){name = "Anonymous";}
                          usrController.clear();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ChatScreen()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}