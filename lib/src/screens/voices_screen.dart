import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import '../widgets/voice_note_widget.dart';

class VoicesScreen extends StatefulWidget {
  final String dirPath;
  VoicesScreen(this.dirPath);

  @override
  State<StatefulWidget> createState() {
    return _VoicesScreenState();
  }
}

class _VoicesScreenState extends State<VoicesScreen> {
  List<File> allVoices = [];

  Future<List<File>> filesInDirectory(Directory dir) async {
    List<File> files = <File>[];
    await for (FileSystemEntity entity
        in dir.list(recursive: false, followLinks: false)) {
      FileSystemEntityType type = await FileSystemEntity.type(entity.path);
      if (type == FileSystemEntityType.file) {
        files.add(entity);
        print(entity.path);
      }
    }
    return files;
  }

  @override
  void initState() {
    super.initState();

    filesInDirectory(Directory(widget.dirPath)).then((files) {
      print(files);
      setState(() {
        allVoices = files;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(basename(widget.dirPath)),
      ),
      body: allVoices.length == 0
          ? Center(
              child: Text('No voices found'),
            )
          : ListView.separated(
              itemCount: allVoices.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext context, int index) {
                return VoiceNote(
                    basename(allVoices[index].path), allVoices[index].path);
              },
            ),
    );
  }
}
