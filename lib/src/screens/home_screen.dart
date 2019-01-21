import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_sound/flutter_sound.dart';
import '../widgets/model_bottom_sheet.dart';
import '../widgets/voice_note_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterSound flutterSound;
  StreamSubscription<RecordStatus> _recorderSubscription;
  // StreamSubscription<PlayStatus> _playerSubscription;
  String _recorderTxt = '00:00:00';
  String _voiceName = '';
  bool _isRecording = false;
  List<String> voiceNames = ['ahmed', 'ali', 'adham', 'khaled'];
  List<String> voiceNotes = [];
  // List<Map<String, String>> voiceNotes = [];
  // Map<String, String> voiceNote;
  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        voiceNotes = prefs.getStringList('voiceNotes');
      });
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  void startRecorder(StateSetter setState) async {
    try {
      String localPath = await _localPath;
      String path =
          await flutterSound.startRecorder('$localPath/$_voiceName.mp4');
      print('startRecorder: $path');
      Map<String, String> newVoiceNote = {
        "voiceName": _voiceName,
        "voiceUri": path
      };
      voiceNotes.add(json.encode(newVoiceNote));

      // setState(() {
      //   voiceNote = newVoiceNote;
      // });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList('voiceNotes', voiceNotes);

      print(prefs.getStringList('voiceNotes'));

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date =
            new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

        setState(() {
          _recorderTxt = txt.substring(0, 8);
        });
      });

      setState(() {
        _isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder(StateSetter setState) async {
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      setState(() {
        _isRecording = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      this.setState(() {
        // voiceNotes.add(voiceNote);
        voiceNotes = prefs.getStringList('voiceNotes');
        print(voiceNotes);
      });

      Navigator.of(context).pop();
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void _openRecordingWidget(context) {
    showModalBottomSheetApp(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 25),
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      onChanged: (String value) {
                        setState(() {
                          _voiceName = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Voice Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide(
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    _isRecording == true
                        ? IconButton(
                            onPressed: () {
                              stopRecorder(setState);
                            },
                            icon: ImageIcon(
                              AssetImage('assets/images/ic_stop.png'),
                              size: 30,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              startRecorder(setState);
                            },
                            icon: ImageIcon(
                              AssetImage('assets/images/ic_mic.png'),
                              size: 30,
                            ),
                          ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: Text(
                      _recorderTxt,
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    )),
                  ],
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    print('from prefs => $voiceNotes');
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: voiceNotes.length == 0
          ? Center(
              child: Text('No Voices Found'),
            )
          : Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: ListView.separated(
                itemCount: voiceNotes.length,
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
                itemBuilder: (BuildContext context, int index) {
                  // return VoiceNote(voiceNotes[index]['voiceName'],
                  //     voiceNotes[index]['voiceUri']);
                  return VoiceNote(jsonDecode(voiceNotes[index])['voiceName'],
                      jsonDecode(voiceNotes[index])['voiceUri']);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openRecordingWidget(context),
        child: Icon(Icons.keyboard_voice),
      ),
    );
  }
}
