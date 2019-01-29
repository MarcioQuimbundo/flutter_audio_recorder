import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:filesize/filesize.dart';
import 'dart:convert';
import '../widgets/dir_widget.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../widgets/model_bottom_sheet.dart';
// import '../widgets/voice_note_widget.dart';

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
  List<String> voiceNotes = [];
  String audioPath;
  String mainPath;
  String dirName;
  List<Directory> allDirVoices = [];

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Future listDir(String folderPath) async {
  //   var directory = new Directory(folderPath);
  //   print(directory);

  //   var exists = await directory.exists();
  //   if (exists) {
  //     print("exits");
  //     directory.list().listen((FileSystemEntity entity) {
  //       if (entity is Directory) {
  //         allDirVoices.add(entity);
  //         print(basename(entity.path));
  //         print(entity.path);
  //       }
  //     });
  //   }
  // }

  Future<List<Directory>> filesInDirectory(Directory dir) async {
    List<Directory> dirs = <Directory>[];
    await for (FileSystemEntity entity
        in dir.list(recursive: false, followLinks: false)) {
      FileSystemEntityType type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.directory) {
        dirs.add(entity);
        print(entity.path);
      }
    }
    return dirs;
  }

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);

    _localPath.then((path) {
      setState(() {
        mainPath = path;
      });
    });

    filesInDirectory(Directory(
            '/data/data/com.example.flutteraudiorecorder/app_flutter/voices/'))
        .then((dirs) {
      print(dirs);
      setState(() {
        allDirVoices = dirs;
      });
    });

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        voiceNotes = prefs.getStringList('voiceNotes') ?? [];
      });
    });
  }

  void startRecorder(StateSetter setState) async {
    try {
      String localPath = await _localPath;
      String path =
          await flutterSound.startRecorder('$localPath/$_voiceName.mp4');
      setState(() {
        audioPath = path;
      });
      print('startRecorder: $path');
      var file = File(path);
      print('file size ${file.lengthSync()}');
      print('file size ${filesize(file.lengthSync())}');
      Map<String, String> newVoiceNote = {
        "voiceName": _voiceName,
        "voiceUri": path
      };
      voiceNotes.add(json.encode(newVoiceNote));

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

      var file = File(audioPath);
      print('file size from stop ${file.lengthSync()}');
      print('file size from stop ${filesize(file.lengthSync())}');

      setState(() {
        _isRecording = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      this.setState(() {
        // voiceNotes.add(voiceNote);
        voiceNotes = prefs.getStringList('voiceNotes');
        print(voiceNotes);
      });

      // Navigator.of(context).pop();
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  // Future<List<DropdownMenuItem>> dropDownItems() async {
  //   List<Directory> dirs =
  //       await filesInDirectory(Directory('$mainPath/voices'));
  //   List<DropdownMenuItem> items = dirs
  //       .map(
  //         (dir) => DropdownMenuItem(
  //               child: Text(
  //                 basename(dir.path),
  //               ),
  //             ),
  //       )
  //       .toList();
  //   return items;
  // }

  void _selectFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AlertDialog(
            title: Center(
              child: Text(
                'Select Folder',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            titlePadding: EdgeInsets.all(10),
            content: ListView.separated(
              itemCount: allDirVoices.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    print('selected folder ${allDirVoices[index].path}');
                  },
                  child: Center(
                    child: Text(
                      basename(allDirVoices[index].path),
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                );
              },
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CLose'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRecordingWidget(context) async {
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
                    Center(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          FlatButton(
                            onPressed: () => _selectFolderDialog(context),
                            child: Text(
                              'SELECT FOLDER',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          Text(
                            'OR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                          FlatButton(
                            onPressed: () => _openAddFolderDialog(context),
                            child: Text(
                              'ADD NEW FOLDER',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
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

  void _createNewDir(BuildContext context) async {
    // create new dir at this path
    print('main path $mainPath');
    Directory dir = await Directory('$mainPath/voices/$dirName').create();
    this.setState(() {
      allDirVoices.add(dir);
    });

    Navigator.of(context).pop();
    print('from create $allDirVoices');
    print('new dir $dir');
  }

  void _openAddFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AlertDialog(
            title: Center(
              child: Text(
                'Create new folder',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            titlePadding: EdgeInsets.all(10),
            content: TextField(
              decoration: InputDecoration(
                labelText: 'Folder Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: BorderSide(
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (String value) {
                setState(() {
                  dirName = value;
                });
                print('folder name :$value');
              },
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CLose'),
              ),
              FlatButton(
                onPressed: () => _createNewDir(context),
                child: Text('Create'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('all dirs $allDirVoices');
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: allDirVoices.length == 0
          ? Center(
              child: Text('No Voices Found'),
            )
          : Container(
              padding: EdgeInsets.all(10),
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: allDirVoices.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      // go to new page and list voice files in it
                    },
                    child: DirButton(basename(allDirVoices[index].path)),
                  );
                },
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _openRecordingWidget(context),
            child: Icon(Icons.keyboard_voice),
          ),
          SizedBox(
            height: 20,
          ),
          FloatingActionButton(
            onPressed: () => _openAddFolderDialog(context),
            child: Icon(Icons.create_new_folder),
          )
        ],
      ),
    );
  }
}
