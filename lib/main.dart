import 'package:flutter/material.dart';
import 'dart:io';
import './src/app.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

void main() async {
  String dir = await _localPath;
  new Directory('$dir/voices').create().then((Directory directory) {
    print('from home => ${directory.path}');
  });
  runApp(MyApp());
}
