// ignore_for_file: avoid_print, library_private_types_in_public_api, unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:window_manager/window_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async{runApp(const MyApp());}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const User(),
    );
  }
}

//Variables
String name = "";
bool sentOnce = false;
List<String> _messages = [];
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
  final msgController = TextEditingController();
  var focusNode = FocusNode();
  final channel = WebSocketChannel.connect(Uri.parse('wss://websocket.dementedelmo.repl.co'));

  @override
  void initState() {
    super.initState();
    channel.sink.add('$name has joined the chat!');
    _messages.insert(0, '$name has joined the chat!');
    sentOnce = false;
    channel.stream.listen((onData){
      final message = onData as String;
      setState(() {
        sentOnce = false;
        _messages.insert(0, message);
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messenger')),
      backgroundColor: bg,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height 
              - kToolbarHeight 
              - MediaQuery.of(context).padding.top 
              - MediaQuery.of(context).padding.bottom
              - 70,
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 17),
                  textColor: fg,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: SizedBox(
              height: 50,
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
                    String strName = "";
                    if(sentOnce == false){
                      strName = "$name: $str"; 
                      sentOnce = true;}
                    else if(sentOnce == true){
                        strName = str;}
                    if(str.isNotEmpty == true){
                      setState(() {_messages.insert(0, strName);});
                      channel.sink.add(strName);}
                    else{sentOnce = false;}
                    msgController.clear();
                    focusNode.requestFocus();
                  },
                ),
              ),
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

  final msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Username Selection')),
      backgroundColor: bg,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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
                                  bg = const Color.fromARGB(255, 53, 53, 53);
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
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
              child: SizedBox(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TextField(
                    controller: msgController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(167, 104, 58, 183), width:1.5)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2.3)),
                        hintText: 'Set your username...',
                        hintStyle: TextStyle(color:hint)),
                    style: TextStyle(color: fg),
                    onSubmitted: (String str) {
                      sentOnce = false;
                      name = str;
                      name.trim();
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