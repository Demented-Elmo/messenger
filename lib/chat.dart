import 'variables.dart';
import 'intro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _messageRef = FirebaseDatabase.instance.ref().child('messages');
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void setState(fn) {if(mounted) {super.setState(fn);}}

  void _sendMessage(String message) {
    _messageRef.push().set({
      'message': message,
      'location': {'latitude': latitude, 'longitude': longitude}
    });
  }

  @override
  void initState() {
    super.initState();
    if(firstJoin==false){_sendMessage('$name has joined the chat!');}
    _messageRef.onChildAdded.listen((event) {
      setState(() {
        Map<dynamic, dynamic> value = event.snapshot.value as Map<dynamic, dynamic>;
        String message = value['message'];
        messages.insert(0, message);
        if(firstJoin==true){
          _sendMessage('$name has joined the chat!');
          firstJoin=false;
        }
      });
    });
  }

  void _handleSubmitted(String str) {
    str = str.trimRight();
    if (str.isNotEmpty) {
      if (sentOnce == false) {
        str = "$name: $str";
        sentOnce = true;}
      if (str.endsWith("has joined the chat!")) {str = "$str ";}
      if (str.endsWith("left the chat.")) {str = "$str ";}
      _sendMessage(str);
    }
    _msgController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _sendMessage('$name has left the chat.');
    _msgController.dispose();
    _focusNode.dispose();
    super.dispose();
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
              Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: bg),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 17, right: 17),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: TextField(
                                      focusNode: _focusNode,
                                      controller: _msgController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        hintText: 'Type a message...',
                                        hintStyle: TextStyle(color: hint),
                                        suffixIcon: IconButton(
                                          color: themeColor,
                                          hoverColor: themeColorT1,
                                          highlightColor: themeColorT2,
                                          icon: const Icon(Icons.send),
                                          onPressed: () => _handleSubmitted(_msgController.text),
                                        ),
                                      ),
                                      style: TextStyle(color: fg),
                                      onSubmitted: _handleSubmitted,
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
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    bottom: 115,
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.only(top: 0, bottom: 17),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              messages[index],
                              style: TextStyle(
                                fontWeight: (messages[index].endsWith('has joined the chat!') ||
                                        messages[index].endsWith('left the chat.'))
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 17),
                            textColor: fg,
                          );
                        },
                      ),
                  ),
                ],
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
                          MaterialPageRoute(builder: (context) => const User()));
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