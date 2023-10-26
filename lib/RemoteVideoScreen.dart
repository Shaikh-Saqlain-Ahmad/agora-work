import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'remote-joiner.dart';

const appId = "14ba67dd02fc410aa273d06cb111f94f";
const token =
    "007eJxTYDDrkpVeG7KhyUBBIJO78qrnL4XGGM/PNS5fb/m+1Ehap6PAYGiSlGhmnpJiYJSWbGJokJhoZG6cYmCWnGRoaJhmaZK25q1FakMgI8Pa1XIsjAwQCOKzMmSk5uTkMzAAANnwHno=";
const channel = "hello";

class RemoteVideoScreen extends StatefulWidget {
  final String? Rid;
  final String? Rtk;
  final String? RCn;
  final int LUID; // Use LUID directly
  final int? uid;

  const RemoteVideoScreen({
    Key? key,
    this.Rid,
    this.Rtk,
    this.RCn,
    required this.LUID, // Use LUID directly
    this.uid,
  }) : super(key: key);

  @override
  State<RemoteVideoScreen> createState() => _RemoteVideoScreenState();
}

class _RemoteVideoScreenState extends State<RemoteVideoScreen> {
  bool isCameraOn = false;
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
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
          debugPrint("remote user $remoteUid left the channel");
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
      uid: widget.LUID,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

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
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.mic),
              onPressed: () {
                // Add the logic to toggle microphone on/off here
              },
            ),
            IconButton(
              icon: Icon(isCameraOn ? Icons.videocam : Icons.videocam_off),
              onPressed: () {
                setState(() {
                  isCameraOn = !isCameraOn;
                  if (isCameraOn) {
                    _engine.enableVideo();
                  } else {
                    _engine.disableVideo();
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.call_end),
              onPressed: () {
                // Add the logic to end the call here
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _remoteVideo() {
    if (widget.LUID != null &&
        appId == widget.Rid &&
        token == widget.Rtk &&
        channel == widget.RCn) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: widget.LUID),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return Text("Wait for the user to join");
    }
  }
}
