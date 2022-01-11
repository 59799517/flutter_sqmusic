import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///2022/1/5
///
class OtherUtils{
  ///显示Toast
  static showToast(String value){
    Fluttertoast.showToast(
        msg: value,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);
  }

}