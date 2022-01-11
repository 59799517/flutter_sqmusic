import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/ToastUtil.dart';

///2022/1/11
///
class AliDriveController  extends GetxController {


  var aliPlayList = {}.obs;

  //刷新数据
  Future RefresPlayListByNameInfo(String name) async {
    await AliClient.RefresPlayListByNameInfo(name);
    aliPlayList.value = SpUtil.getObject(SetKey.ALI_MUSICDATA)!;
  }

  //刷新全部
  Future RefresPlayListAllnfo() async {
    await AliClient.RefreshPlaylistInfo();
    aliPlayList.value = SpUtil.getObject(SetKey.ALI_MUSICDATA)!;
  }

  //刷新数据
  Future Refres() async {
    aliPlayList.value = SpUtil.getObject(SetKey.ALI_MUSICDATA)!;
  }


  }






