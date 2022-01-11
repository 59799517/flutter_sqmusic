import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/%20steam/MusicSteam.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/set/PlaySongSource.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:sqmusic/widget/FLListTile.dart';

///2022/1/10
///
class AliDrivePlayListPage extends StatefulWidget {
  const AliDrivePlayListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AliDrivePlayListPage();
}

class _AliDrivePlayListPage extends State<AliDrivePlayListPage> {
  Size? size;
  List<Widget> tempWidget = [];
  var body = Container().obs;
  AliDriveController controller = Get.find<AliDriveController>();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Container(
                height: size!.height,
                width: size!.width,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: LineIcon.arrowLeft(),
                              color: Colors.black,
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            Container(
                              child: Text(
                                "搜索",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            Container(
                              child: IconButton(
                                icon: Icon(Icons.more_horiz),
                                color: Colors.black,
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        height: size!.height,
                        width: size!.width,
                        // color: Colors.amber,
                        child: Obx(()=>body.value)
                        ,
                      ),
                    ),
                  ],
                ))));
  }

  @override
  void initState() {
    controller.aliPlayList.listen((p0) {
      initData();
    });
    Future.delayed(Duration.zero, () {
      initData();
    });
  }

  Future initData() async {
    tempWidget = [];
    body.value = Container();
    print(Get.arguments);
    //全部数据
    Map alisonginfo = controller.aliPlayList.value[Get.arguments];
    for (String name in alisonginfo.keys) {
      var split = name.split(" - ");
      //歌曲名称
      String songname = split[0];
      //歌手
      String artist = split[1];
      String imageurl = controller.aliPlayList.value[Get.arguments]
          [name]["image"]["url"];
      String imagesize = controller.aliPlayList.value[Get.arguments]
              [name]["image"]["size"]
          .toString();

      tempWidget.add(Slidable(
        child: GFListTile(
            onTap: () {
              //跳转到播放页面
              // 获取单个json
              var data = {};
              AliClient.aliSongInfoToJson(
                  controller.aliPlayList.value[Get.arguments]
                          [name]["json"]["download_url"],
                  controller.aliPlayList.value[Get.arguments]
                              [name]["json"]["size"]
                          .toString())
                  .then((value) => {
                        if (value != null)
                          {
                            //稍后修改
                            data = json.decode(value),
                            Get.toNamed("/musicplay", arguments: {
                              "refresh": true,
                              "data": data,
                              "songSource": PlaySongSource.KuWo,
                              "id": data,
                              "isdrive": true,
                              "dirveinfo": controller.aliPlayList.value[Get.arguments][name]
                            })
                          }
                        else
                          {
                            //检测到未发现歌曲详情信息
                            OtherUtils.showToast("未发现歌曲详情信息，请删除该歌曲")
                          }
                      });

              // printInfo(info: "3123213123");
            },
            avatar: ExtendedImage.network(
              imageurl,
              height: size!.height * 0.08,
              headers: {
                'Authorization': 'Bearer ' + AliClient.authorization,
                "Referer": "https://www.aliyundrive.com/",
                "RANGE": "bytes=0-${imagesize}"
              },
            ),
            titleText: songname,
            subTitleText: artist,
            icon: Icon(LineIcons.angleRight)),
        endActionPane: ActionPane(
          motion: ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (s) {
                Alert(context: context, title: "是否删除该歌曲", buttons: [
                  DialogButton(
                      color: Colors.transparent,
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        "取消",
                        style: TextStyle(color: Colors.blue, fontSize: 20),
                      )),
                  DialogButton(
                    color: Colors.transparent,
                    onPressed: () {
                      Get.back();
                      AliClient.delSong(controller.aliPlayList.value[Get.arguments][name])
                          .then((value) => {
                                //刷新页面
                                alisonginfo.remove(name),
                        controller.aliPlayList.value[Get.arguments] = alisonginfo,
                                SpUtil.remove(SetKey.ALI_MUSICDATA),
                                SpUtil.putObject(SetKey.ALI_MUSICDATA, controller.aliPlayList.value),
//                                删除数据
                                initData().then((value) => {
                                  controller.Refres()
                                })
                              });
                    },
                    child: Text(
                      "确定",
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    ),
                  )
                ]).show();
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: LineIcons.trash,
              label: '删除',
            ),
          ],
        ),
      ));
    }
    body.value = Container(child: new ListView(children: tempWidget),) ;

    // Obx(()=>body);

  }
// @override
// void deactivate(){
//   MusicSteam.AliDrivePlayListPageSteam.close();
//   super.deactivate();
//
// }

}
