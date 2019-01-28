import 'package:flutter/material.dart';

class DirButton extends StatelessWidget {
  final String dirName;
  DirButton(this.dirName);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Column(
        children: <Widget>[
          Image.asset('assets/images/dir.png'),
          SizedBox(
            height: 3,
          ),
          Container(
            width: 100,
            
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Center(
              child: Text(
                '$dirName',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
