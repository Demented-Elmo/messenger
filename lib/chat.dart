import 'dart:convert';
import 'variables.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() {return _ChatScreenState();}}

class _ChatScreenState extends State<ChatScreen> {
  final channel = WebSocketChannel.connect(Uri.parse('wss://websocket.dementedelmo.repl.co'));

  void _handleSubmitted(String str) {
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
      setState(() {messages.insert(0, str);});
      var dataToSend = {
        'message': str,
        'location': {'latitude': latitude, 'longitude': longitude,}
      };
      channel.sink.add(jsonEncode(dataToSend));
    }
    msgController.clear();
    focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    if (joinedOnce == true){messages.insert(0, '------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');}
    joinedOnce = true;
    var dataToSend = {'message': '$name has joined the chat!','location': {'latitude': latitude, 'longitude': longitude,}};
    channel.sink.add(jsonEncode(dataToSend));
    messages.insert(0, '$name has joined the chat!');
    sentOnce = false;
    channel.stream.listen((message) {
      setState(() {
        if (int.tryParse(message) != null) {users = int.parse(message);} 
        else {
          sentOnce = false;
          messages.insert(0, message.substring(1));
        }
      });
      },
    );
  }

  @override
  void dispose() {
    while(messages.contains('------ ⬆️ PREVIOUS MESSAGES ⬆️ ------')){
      messages.remove('------ ⬆️ PREVIOUS MESSAGES ⬆️ ------');}
    var dataToSend = {'message': '$name has left the chat.','location': {'latitude': latitude, 'longitude': longitude,}};
    channel.sink.add(jsonEncode(dataToSend));
    messages.insert(0, 'You left the chat.');
    channel.sink.close(); 
    super.dispose();}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messenger'), backgroundColor: themeColor,),
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index],
                    style: TextStyle(
                      fontWeight: (messages[index].endsWith('has joined the chat!') || messages[index].endsWith('left the chat.')) ? FontWeight.bold : FontWeight.normal,
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
                              setState(() {messages.insert(0, str);});
                              var dataToSend = {
                                'message': str,
                                'location': {'latitude': latitude, 'longitude': longitude,}
                              };
                              channel.sink.add(jsonEncode(dataToSend));
                            }
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