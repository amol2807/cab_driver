import 'package:flutter/material.dart';

class AvailabilityButton extends StatelessWidget {
  final String title;
  final Color color;
  final Function onPressed;

  AvailabilityButton({this.title, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: onPressed,
      color: color,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        height: 50.0,
        width: 200,
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20.0, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}
