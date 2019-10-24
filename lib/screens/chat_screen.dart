import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id='chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth=FirebaseAuth.instance;
  final _firestore=Firestore.instance;
  String messageText;
  FirebaseUser loggedInUser;
  
  @override
  void initState(){
    super.initState();
    getCurrentUser();    
  }


  void getCurrentUser() async{
    try{
      final user = await _auth.currentUser();
      if (user!=null){
        loggedInUser=user;
      }

    }
    catch (e){
        print(e);
      }
    
  }


  // void getMessages() async{
  //   final messages = await _firestore.collection('Messages').getDocuments();
  //   for (var message in messages.documents){

  //   }
  // }


  //this method below retrieves data from firestore
  void messagesStream() async{
    await for (var snapshot in _firestore.collection('Messages').snapshots()){
      for (var message in snapshot.documents){
        print (message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            //this is where we are going to retrieve from our firestore using the streambuilder widget 
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Messages').snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),);
                }

                final messages = snapshot.data.documents;
                List<Text> messageWidgets = [];
                for (var message in messages){
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];

                  final messageWidget = Text('$messageText from $messageSender');
                  messageWidgets.add(messageWidget);
                }
                return Column(children: messageWidgets);
              }
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality. this is how to send datat to the cloud firestore
                      _firestore.collection('Messages').add({
                        'text':messageText,
                        'sender':loggedInUser
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
