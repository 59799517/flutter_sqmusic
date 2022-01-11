import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


/// 歌曲图像
class MusicPlayImageWidge extends StatelessWidget {
  String imagepath = "";
  Map lyrics =Map();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var image  =ExtendedImage.network(
      imagepath,
      width: size.width * 0.9,
      height: size.width * 0.9,
      fit: BoxFit.fill,
      cache: true,
    );
    return InkWell(
      child: Center(
          child: Container(
            // color: Colors.yellow,
            // child: ClipOval(
            //   child: image,
            // ),
              child: image,
            // width: size.width * 0.5,
            // height: size.width * 0.5,
            // color: AppTheme.white
          )),
    );
  }

  MusicPlayImageWidge(String imagepath) {
    this.imagepath = imagepath;

  }
}