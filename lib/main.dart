// ignore_for_file: avoid_print, unused_import, library_private_types_in_public_api
// Github: https://github.com/Demented-Elmo/messenger/actions
// Website: https://demented-elmo.github.io/messenger/#/
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
      channel.sink.add(str);}
    msgController.clear();
    focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (joinedOnce == true){_messages.insert(0, '------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');}
    joinedOnce = true;
    channel.sink.add('$name has joined the chat!');
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
      _messages.remove('------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');
    }
    channel.sink.add('$name left the chat.');
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
                              channel.sink.add(str);}
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
              padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
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