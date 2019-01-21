import 'package:flutter/material.dart';
import 'dart:async';
// import 'dart:convert';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';

class VoiceNote extends StatefulWidget {
  final String voiceName;
  final String voiceUri;
  VoiceNote(this.voiceName, this.voiceUri);
  @override
  State<StatefulWidget> createState() {
    return _VoiceNoteState();
  }
}

class _VoiceNoteState extends State<VoiceNote> {
  FlutterSound flutterSound;
  StreamSubscription<PlayStatus> _playerSubscription;
  String _playerTxt = '00:00:00';
  bool _isPlaying = false;

  @override
  void initState() {
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
    super.initState();
  }

  void startPlayer() async {
    String path = await flutterSound.startPlayer(widget.voiceUri);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt());
          String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
          setState(() {
            _isPlaying = true;
            _playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async {
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        _isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async{
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(widget.voiceName),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              _playerTxt,
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 83,
                ),
                IconButton(
                  onPressed: () {
                    startPlayer();
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/ic_play.png'),
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    pausePlayer();
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/ic_pause.png'),
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    stopPlayer();
                  },
                  icon: ImageIcon(
                    AssetImage('assets/images/ic_stop.png'),
                    size: 30,
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
