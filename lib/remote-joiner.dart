import 'package:flutter/material.dart';
import 'package:rough/RemoteVideoScreen.dart';
import 'package:rough/VideoScreen.dart';

class RemoteInfoScreen extends StatefulWidget {
  @override
  _RemoteInfoScreenState createState() => _RemoteInfoScreenState();
}

class _RemoteInfoScreenState extends State<RemoteInfoScreen> {
  // Variables to store the input values
  String remoteAppId = '14ba67dd02fc410aa273d06cb111f94f';
  String remoteToken = '007eJxTYDDrkpVeG7KhyUBBIJO78qrnL4XGGM/PNS5fb/m+1Ehap6PAYGiSlGhmnpJiYJSWbGJokJhoZG6cYmCWnGRoaJhmaZK25q1FakMgI8Pa1XIsjAwQCOKzMmSk5uTkMzAAANnwHno=';
  String remoteChannelName = '';

  // TextEditingController for the TextFormFields
  //final TextEditingController appIdController = TextEditingController();
  //final TextEditingController tokenController = TextEditingController();
  final TextEditingController channelNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remote App Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[


            TextFormField(
              controller: channelNameController,
              decoration: InputDecoration(labelText: 'Remote Channel Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Store the input values in variables

                  remoteChannelName = channelNameController.text;
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(Rid: remoteAppId, Rtk: remoteToken, RCn: remoteChannelName),));
                  Navigator.push(context,MaterialPageRoute(builder: (context) => RemoteVideoScreen(Rid: remoteAppId, Rtk: remoteToken, RCn: remoteChannelName,LUID: LocalUserIdsaqlain),));

                });
              },
              child: Text('Join Call'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the TextEditingController objects

    channelNameController.dispose();
    super.dispose();
  }
}
