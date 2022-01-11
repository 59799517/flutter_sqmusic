import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListContainer extends StatelessWidget{
  Size? size;
  String _name;
  String _image;
  int _id;
  ListContainer(this._name, this._image,this._id);

  @override
  Widget build(BuildContext context) {
    size=MediaQuery.of(context).size;

    return InkWell(
      // key: ,
      child: Container(
        padding: EdgeInsets.only(
            right:size!.height*0.01,
            // left: size.height*0.01
        ),
        child: Column(
          children: [
            ExtendedImage.network(
              _image,
              width: size!.height*0.15,
              height: size!.height*0.15,
              fit: BoxFit.fill,
              cache: true,
            ),
            SizedBox(height: size!.height*0.005,),
            Text(_name,style: TextStyle(fontSize: size!.height*0.015),),
          ],
        ),
      ),
      onTap: (){
        Get.toNamed("/kuwobanglist",arguments: {"id":_id,"name":_name});
        // print(_id);
      },
    );
  }

}