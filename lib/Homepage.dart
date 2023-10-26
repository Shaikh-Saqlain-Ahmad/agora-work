import 'package:flutter/material.dart';
import 'package:rough/VideoScreen.dart';
import 'package:rough/remote-joiner.dart';

class UserSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder:(context) =>  VideoScreen(uid: 1) ,));
              },
              child: Text('Local User'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder:(context) =>  RemoteInfoScreen() ,));
              },
              child: Text('Remote User'),
            ),
          ],
        ),
      ),
    );
  }
}
