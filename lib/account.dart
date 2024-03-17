// ignore_for_file: avoid_print
import 'variables.dart';
import 'intro.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() {return _LoginState();}}

class _LoginState extends State<Login> {

  void _accountComplete() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const User()),
    );
  }

  @override
  void initState() {
    try{
    googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        currentUser = account;
      });
    });
    googleSignIn.signInSilently();
    }catch(error){
      print('Error: $error');
    }
    super.initState();
  }

  Future<void> handleSingIn() async{
    try{
      await googleSignIn.signIn();
    } catch(error){
      print('Error: $error');
    }
  }

  Widget buildBody(){
    if(currentUser!=null){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GoogleUserCircleAvatar(identity: currentUser!),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentUser!.displayName ?? '', textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                currentUser!.email, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
              ),
            ),
          ),
          ElevatedButton(onPressed: handleSignOut, child: const Text('Sign Out')),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: ElevatedButton(
              onPressed: _accountComplete, 
              child: const Text('Continue')
            ),
          )
        ],
      );
    } else{
      return Column(
        children: [
          Center(
            child: ElevatedButton(onPressed: handleSingIn, child: const Text('Sign in')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(onPressed: _accountComplete, child: const Text('Skip (Dev)')),
            ),
          )
        ],
      );
    }
  }

  Future<void> handleSignOut() async {
    await googleSignIn.disconnect();
    setState(() {
      currentUser = null;
    });
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: themeColor, toolbarHeight: 5),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          height: MediaQuery.of(context).size.height,
          color: bg,
          child: Center(
            child: SingleChildScrollView(
              child: buildBody()
            ),
          ),
        ),
      ),
    );
  }
}