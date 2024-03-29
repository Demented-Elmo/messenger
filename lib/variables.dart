import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
String name = "";
double radius = 50;
double latitude = 0;
double longitude = 0;
bool testing = false;
bool firstJoin = true;
bool sentOnce = true;
bool joinedOnce = false;
bool gotLocation = false;
List<String> messages = [];
List<String> usernames = [];
List<bool> joins = [];
List<Circle> circles = [];
List<Marker> markers = [];
var focusNode = FocusNode();
GoogleSignInAccount? currentUser;
enum SingingCharacter {light, dark}
final Location location = Location();
LatLng currentLocation = const LatLng(0, 0);
final msgController = TextEditingController();
final usrController = TextEditingController();
SingingCharacter? character = SingingCharacter.light;
MaterialColor themeColor = Colors.deepPurple;
Color themeColorT1 = const Color.fromARGB(60, 104, 58, 183);
Color themeColorT2 = const Color.fromARGB(99, 104, 58, 183);
Color fg = const Color.fromARGB(255, 29, 29, 29);
Color bg = const Color.fromARGB(255, 255, 255, 255);
Color hint = const Color.fromARGB(255, 95, 95, 95);