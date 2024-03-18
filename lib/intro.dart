import 'chat.dart';
import 'dart:async';
import 'account.dart';
import 'variables.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class User extends StatefulWidget {
  const User({super.key});
  @override
  State<User> createState() {return _UserState();}}

class _UserState extends State<User> {
  final Completer<GoogleMapController> mapsController = Completer<GoogleMapController>();
  String usernameHintText = 'Set your username...';

  void _nameSubmitted(String nameRaw) {
    if(gotLocation==true){
      sentOnce = false;
      name = nameRaw.trim();
      if(name.isEmpty == true){name = "Anonymous";}
      usrController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    }
    else{
      setState(() {
        usrController.clear();
        usernameHintText = 'Please get your location first!';
      });
    }
  }

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
    gotLocation = true;
    final GoogleMapController controller = await mapsController.future;
    final newCameraPosition = CameraPosition(target: currentLocation, zoom: 17.0, tilt: 45.0);
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
    setState(() {radius = newRadius;});
    _goToLocation();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(onTap:(){FocusManager.instance.primaryFocus?.unfocus();},
    child: Scaffold(
      appBar: AppBar(backgroundColor: themeColor, toolbarHeight: 5),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          height: MediaQuery.of(context).size.height,
          color: bg,
          child: Stack(
            children: [
              Center(
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
                                  if (!mapsController.isCompleted) {
                                    mapsController.complete(controller);
                                  }
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
                          child: SizedBox(
                            height:50,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 0),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 337.837838),
                          width: MediaQuery.of(context).size.width / 1.48,
                          child: Slider(
                            inactiveColor: themeColorT2,
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
                          alignment: Alignment.center,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>  setState(() {
                                      fg = const Color.fromARGB(255, 29, 29, 29);
                                      bg = const Color.fromARGB(255, 255, 255, 255);
                                      hint = const Color.fromARGB(255, 95, 95, 95);
                                      character = SingingCharacter.light;
                                    }),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:0),
                                      child: ListTileTheme(
                                        horizontalTitleGap: 16,
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
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>  setState(() {
                                      fg = const Color.fromARGB(255, 255, 255, 255);
                                      bg = const Color.fromARGB(255, 37, 37, 37);
                                      hint = const Color.fromARGB(228, 255, 255, 255);
                                      character = SingingCharacter.dark;
                                    }),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right:0),
                                      child: ListTileTheme(
                                        horizontalTitleGap: 16,
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
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: TextField(
                              controller: usrController,
                              autofocus: false,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromARGB(167, 104, 58, 183), width:2)),
                                focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepPurple, width: 2.3)),
                                hintText: usernameHintText,
                                hintStyle: TextStyle(color:hint),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right:8),
                                  child: IconButton(
                                    color: themeColor,
                                    hoverColor: themeColorT1,
                                    highlightColor: themeColorT2,
                                    icon: const Icon(Icons.send),
                                    onPressed: () => _nameSubmitted(usrController.text),
                                  ),
                                ),
                              ),
                              style: TextStyle(color: fg),
                              onSubmitted: (String nameRaw) {
                                if(gotLocation==true){
                                  sentOnce = false;
                                  name = nameRaw.trim();
                                  if(name.isEmpty == true){name = "Anonymous";}
                                  usrController.clear();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                                  );
                                }
                                else{
                                  setState(() {
                                    usrController.clear();
                                    usernameHintText = 'Please get your location first!';
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: IconTheme(
                    data: const IconThemeData(
                    color: Colors.white),
                    child: IconButton(
                      onPressed:() {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()), );
                          }, 
                      icon: const Icon(Icons.arrow_back)
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