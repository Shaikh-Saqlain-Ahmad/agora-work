import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


const appId = "9d302c601c1e408eb7481c759c171916";
const token =
    "007eJxTYJCsL/fJanj/zXqOl9fhCxviNH2eCv7bduWS+YVM/5zQH98VGCxTjA2Mks0MDJMNU00MLFKTzE0sDJPNTS2TDc0NLQ3NVAOtUhsCGRl6Be8zMTJAIIjPypCRmpOTz8AAALJEIAA=";
const channel = "hello";




class VideoScreen extends StatefulWidget {
  final String? Rid;
  final String? Rtk;
  final String? RCn;
  final int? uid;
  const VideoScreen(
      { Key? key,
         this.Rid,
         this.Rtk,
         this.RCn,
        this.uid
        }) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> with WidgetsBindingObserver {
  bool isCameraOn=false;
  int? _remoteUid;
  bool _localUserJoined = false;
  bool isVideoEnabled = true;
  bool isAppInBackground = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    initAgora();

  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      // The app is in the background
        isAppInBackground = true;
        _engine.disableVideo();
        break;
      case AppLifecycleState.resumed:
      // The app is in the foreground
        isAppInBackground = false;
        _engine.enableVideo();
        break;
      default:
      // The app is in an unknown state
        break;
    }
  }

  Future<void> initAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    //create the engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");

          setState(() {
            _localUserJoined = true;

          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          final calleeId = remoteUid;
          print("the id of callee is $calleeId");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();

    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _engine.disableVideo();
    WidgetsBinding.instance!.removeObserver(this);


    _dispose();
  }
  void disableVideo() {
    isVideoEnabled = false;
    _engine.disableVideo();
  }

  // Enable video
  void enableVideo() {
    isVideoEnabled = true;
    _engine.enableVideo();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: _localUserJoined && isCameraOn
                    ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent, // Make the bar transparent
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.mic), // Replace with your microphone icon
              onPressed: () {
                // Add the logic to toggle microphone on/off here
              },
            ),
            IconButton(
              icon: Icon(isCameraOn?Icons.videocam:Icons.videocam_off), // Camera icon
              onPressed: () {
                setState(() {
                  isCameraOn=!isCameraOn;
                  if(isCameraOn){
                    _engine.enableVideo();
                  }else{
                    _engine.disableVideo();
                  }

                });
              },
            ),
            IconButton(
              icon: Icon(Icons.call_end), // Call end icon
              onPressed: () {
                // Add the logic to end the call here
              },
            ),
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null  ) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    }
    else{
      return CircularProgressIndicator();
    }
  }
}
