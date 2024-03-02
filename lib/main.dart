// ignore_for_file: avoid_print, library_private_types_in_public_api
// Github: https://github.com/Demented-Elmo/messenger/actions
// Website: https://demented-elmo.github.io/messenger/#/
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//test

void main() async{runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger App',
      theme: ThemeData(
        primarySwatch: themeColor,
        unselectedWidgetColor:themeColor),
      home: const User(),
    );
  }
}
//Variables
int users = 0;
String name = "";
bool sentOnce = false;
bool joinedOnce = false;
List<String> _messages = [];
List<Circle> _circles = [];
List<Marker> _markers = [];
double latitude = 0;
double longitude = 0;
MaterialColor themeColor = Colors.deepPurple;
Color themeColorT1 = const Color.fromARGB(60, 104, 58, 183);
Color themeColorT2 = const Color.fromARGB(99, 104, 58, 183);
Color fg = const Color.fromARGB(255, 29, 29, 29);
Color bg = const Color.fromARGB(255, 255, 255, 255);
Color hint = const Color.fromARGB(255, 95, 95, 95);
enum SingingCharacter {light, dark}

//                  //
//                  //
// MESSENGER SCREEN //
//                  //
//                  //

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();}

class _ChatScreenState extends State<ChatScreen> {
  final channel = WebSocketChannel.connect(Uri.parse('wss://websocket.dementedelmo.repl.co'));
  final msgController = TextEditingController();
  var focusNode = FocusNode();

  void _handleSubmitted(String str) {
    str = str.trimRight();
    if(str.isNotEmpty == true){
      if(sentOnce == false){
        str = "$name: $str"; 
        sentOnce = true;}
      setState(() {_messages.insert(0, str);});
      var dataToSend = {'message': str,'location': {'latitude': latitude, 'longitude': longitude,}};
      channel.sink.add(jsonEncode(dataToSend));}
    msgController.clear();
    focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (joinedOnce == true){_messages.insert(0, '------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');}
    joinedOnce = true;
    var dataToSend = {'message': '$name has joined the chat!','location': {'latitude': latitude, 'longitude': longitude,}};
    channel.sink.add(jsonEncode(dataToSend));
    _messages.insert(0, '$name has joined the chat!');
    sentOnce = false;
    channel.stream.listen((message) {
      setState(() {
        if (int.tryParse(message) != null) {users = int.parse(message);} 
        else {
          sentOnce = false;
          _messages.insert(0, message.substring(1));
        }
      });
      },
    );
  }

  @override
  void dispose() {
    while(_messages.contains('------ ⬆️ PREVIOUS MESSAGES ⬆️ ------')){
      _messages.remove('------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');}
    var dataToSend = {'message': '$name has left the chat.','location': {'latitude': latitude, 'longitude': longitude,}};
    channel.sink.add(jsonEncode(dataToSend));
    _messages.insert(0, 'You left the chat.');
    channel.sink.close(); 
    super.dispose();}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messenger')),
      backgroundColor: bg,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(bottom:BorderSide(color: themeColor, width: 3)),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                child: Text(
                    "Users Online: $users",
                    style: TextStyle(color: fg),
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height 
              - kToolbarHeight 
              - MediaQuery.of(context).padding.top 
              - MediaQuery.of(context).padding.bottom
              - 110,
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index],
                    style: TextStyle(
                      fontWeight: (_messages[index].endsWith('has joined the chat!') || _messages[index].endsWith('left the chat.')) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 17),
                  textColor: fg,
                );
              },
            ),
          ),
          Expanded(
            child: Row(
              children:[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 10, top: 0, bottom: 0),
                    child: SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: TextField(
                          focusNode: focusNode,
                          controller: msgController,
                          autofocus: true,
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color:hint)),
                          style: TextStyle(color: fg),
                          onSubmitted: (String str) {
                            str = str.trimRight();
                            if(str.isNotEmpty == true){
                              if(sentOnce == false){
                                str = "$name: $str"; 
                                sentOnce = true;}
                              if(str.endsWith("has joined the chat!")){
                                str = "$str ";
                              }
                              if(str.endsWith("left the chat.")){
                                str = "$str ";
                              }
                              setState(() {_messages.insert(0, str);});
                              var dataToSend = {
                                'message': str,
                                'location': {'latitude': latitude, 'longitude': longitude,}
                              };
                              channel.sink.add(jsonEncode(dataToSend));}
                            msgController.clear();
                            focusNode.requestFocus();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 0, right: 10, top: 0, bottom: 0),
                  child: SizedBox(
                    height: 40,
                    child: Align(
                      alignment: Alignment.bottomRight,
                        child: IconButton(
                          color: themeColor,
                          hoverColor: themeColorT1,
                          highlightColor: themeColorT2,
                          icon: const Icon(Icons.send),
                          onPressed: () => _handleSubmitted(msgController.text)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//                 //
//                 //
// USERNAME SCREEN //
//                 //
//                 //

class User extends StatefulWidget {
  const User({Key? key}) : super(key: key);
  @override
  _UserState createState() => _UserState();}

class _UserState extends State<User> {
  SingingCharacter? _character = SingingCharacter.light;
  final Completer<GoogleMapController> _mapsController = Completer<GoogleMapController>();
  final msgController = TextEditingController();
  final Location _location = Location();
  LatLng _currentLocation = const LatLng(0.0, 0.0);

  double radius = 50;

  Future<void> _getLocation() async {
    LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

  Future<void> _goToLocation() async {
    if (_currentLocation.latitude == 0.0 && _currentLocation.longitude == 0.0) {await _getLocation();}
    final GoogleMapController controller = await _mapsController.future;
    
    final newCameraPosition = CameraPosition(
      target: _currentLocation,
      zoom: 17.0,
      tilt: 45.0,);

    controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
    
    _circles.clear();
    const circleId = CircleId('user_location_circle');
    var circle = Circle(
      circleId: circleId,
      center: _currentLocation,
      radius: radius,
      fillColor: Colors.blue.withOpacity(0.3),
      strokeColor: Colors.blue,
      strokeWidth: 3,
    );

    _circles.add(circle);



    _markers.clear();
    const MarkerId markerId = MarkerId('user_location_marker');
    final Marker marker = Marker(
      markerId: markerId,
      position: _currentLocation,
      icon: BitmapDescriptor.defaultMarker,
      onTap: _goToLocation,
    );
    _markers.add(marker);
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
      appBar: AppBar(title: const Text('Username Selection')),
      backgroundColor: bg,
      body: Column(
        children: [
          SizedBox(
            height: 370,
            width: 370,
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 1,
              ),
              circles: Set.from(_circles),
              markers: Set.from(_markers),
              onMapCreated: (GoogleMapController controller) { 
                _mapsController.complete(controller);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 0),
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
          Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 0),
            child: Slider(
              value: radius,
              min: 10,
              max: 100,
              divisions: 9,
              label: radius.round().toString(),
              onChanged: updateRadius,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 15),
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
                            groupValue: _character,
                            onChanged: (SingingCharacter? value){
                              setState(() {
                                fg = const Color.fromARGB(255, 29, 29, 29);
                                bg = const Color.fromARGB(255, 255, 255, 255);
                                hint = const Color.fromARGB(255, 95, 95, 95);
                                _character = value;
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
                              groupValue: _character,
                              onChanged: (SingingCharacter? value){
                                setState(() {
                                  fg = const Color.fromARGB(255, 255, 255, 255);
                                  bg = const Color.fromARGB(255, 37, 37, 37);
                                  hint = const Color.fromARGB(228, 255, 255, 255);
                                  _character = value;
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 10),
              child: SizedBox(
                width: 350,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TextField(
                    controller: msgController,
                    autofocus: true,
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
                      msgController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatScreen()),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}