import 'variables.dart';
import 'intro.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//TODO: User's messages on one side, possibly email validation?

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver{
  final DatabaseReference _messageRef = FirebaseDatabase.instance.ref().child('messages');
  final TextEditingController _msgController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int users = 0;

  @override
  void setState(fn) {if(mounted) {super.setState(fn);}}

  void _sendMessage(String message, String username, bool join, int count) {
    _messageRef.push().set({
      'message': message,
      'location': {'latitude': latitude, 'longitude': longitude},
      'username': username,
      'joinMessage': join,
      'userCount': count,
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messageRef.onChildAdded.listen((event) {
      setState(() {
        Map<dynamic, dynamic> value = event.snapshot.value as Map<dynamic, dynamic>;
        String ?message = value['message'];
        String ?username = value['username'];
        bool ?joinMessage = value['joinMessage'];
        int ?userCount = value['userCount'];
        if(message != null && username !=null && joinMessage !=null){
          usernames.insert(0, username);
          joins.insert(0, joinMessage);
          if(userCount!=null){users = users + userCount;}
          if(firstJoin==true){
            _sendMessage('$name has joined the chat!', name, true, 1);
            firstJoin=false;}
          else if(joinMessage==true){messages.insert(0, message);}
          else if((joins[1]==true)){messages.insert(0, "$username: $message");}
          else if(username.length >= 2){
            if (username == usernames[1]) {messages.insert(0, message);}
            else{messages.insert(0, "$username: $message");}}
          else{messages.insert(0, "$username: $message");}
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    final isClosed = state == AppLifecycleState.detached;
    if(isClosed){
      _sendMessage('$name has left the chat.', name, true, -1);
    }
  }

  void _handleSubmitted(String str) {
    str = str.trimRight();
    if (str.isNotEmpty) {_sendMessage(str, name, false, 0);}
    _msgController.clear();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    firstJoin = true;
    _sendMessage('$name has left the chat.', name, true, -1);
    WidgetsBinding.instance.removeObserver(this);
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
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: IconTheme(
                    data: IconThemeData(
                    color: bg),
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
              /*
              Reset User Count Later, too many bugs
              Positioned(
                right:8,
                top:8,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      '$users',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: bg, fontSize: 25),
                    ),
                  )
                ),
              ),
              */
            ],
          ),
        ),
      ),
    ),
  );
}