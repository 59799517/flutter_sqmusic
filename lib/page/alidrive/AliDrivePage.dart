import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/ToastUtil.dart';

///2022/1/5
///
class AliDrivePage extends StatefulWidget {
  const AliDrivePage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _AliDrivePage();
}

class _AliDrivePage extends State<AliDrivePage> {
  Widget? mylikesimages;
  var body = Container().obs;
  Widget? avatar;
  Size? size;

  //阿里云用户信息
  String nick_name = "";

  //新增歌单等信息的数据
  String? inputvalue;

  //是否正在刷新
  bool isres = false;
  AliDriveController controller = Get.find<AliDriveController>();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Container(
          height: size!.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text(
                        "",
                        style: TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        color: Colors.black,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  height: size!.height,
                  // color: Colors.white,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0)),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                height: size!.height,
                                width: size!.width,
                                child: avatar,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  alignment: Alignment(0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25.0),
                        bottomRight: Radius.circular(25.0)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: size!.height,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(nick_name, style: TextStyle(fontSize: 20)),
                              GFButton(
                                onPressed: () {
                                  Alert(
                                      style: AlertStyle(
                                          // backgroundColor: MyColors.MainBackgroundColor,
                                          // titleStyle: TextStyle(color: Colors.white)
                                          ),
                                      context: context,
                                      title: "新增歌单",
                                      content: Column(
                                        children: <Widget>[
                                          TextField(
                                            decoration: InputDecoration(
                                                // icon: Icon(Icons.account_circle),
                                                // labelText: 'Username',
                                                ),
                                            onChanged: (value) {
                                              inputvalue = value;
                                            },
                                          ),
                                          // TextField(
                                          //   obscureText: true,
                                          //   decoration: InputDecoration(
                                          //     icon: Icon(Icons.lock),
                                          //     labelText: 'Password',
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      buttons: [
                                        DialogButton(
                                            color: Colors.transparent,
                                            onPressed: () {
                                              Get.back();
                                            },
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 20),
                                            )),
                                        DialogButton(
                                          color: Colors.transparent,
                                          onPressed: () {
                                            if (inputvalue != null) {
                                              Get.back();
                                              AliClient.existMusicDirectory()
                                                  .then((sqmusicpath) => {
                                                        AliClient.mkdir(
                                                                sqmusicpath,
                                                                inputvalue)
                                                            .then((value) => {
                                                                  //刷新页面
                                                                  refresh().then(
                                                                      (value) =>
                                                                          {
                                                                            Get.offAndToNamed("/home",
                                                                                arguments: 1)
                                                                          })
                                                                })
                                                      });
                                            } else {
                                              OtherUtils.showToast("请输入歌单名称");
                                            }
                                          },
                                          child: Text(
                                            "确定",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 20),
                                          ),
                                        )
                                      ]).show();
                                },
                                text: "新增歌单",
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                ),
                                type: GFButtonType.outline,
                                shape: GFButtonShape.pills,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Expanded(
                flex: 10,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0)),
                      color: Colors.white,
                    ),
                    child: mylikesimages == null
                        ? Text("")
                        : isres
                            ? Container(
                                color: Colors.white,
                                height: size!.height,
                                width: size!.width,
                                child: GFLoader(
                                    loaderstrokeWidth: 1,
                                    duration: Duration(days: 1)),
                              )
                            : RefreshIndicator(
                                child: Obx(()=>body.value),
                                onRefresh: () async {
                                  print("31231");
                                  refresh();
                                },
                              )),
              ),
            ],
          ),
        )));
  }

  @override
  void initState() {
    controller.aliPlayList.listen((p0) {
      initData();
    });
    //没开启云盘不能使用
    Future.delayed(Duration.zero, () {
      initData();
    });
  }
  refresh() async {
    setState(() {
      isres = true;
    });
    //刷新歌曲信息
    await controller.RefresPlayListAllnfo();
    setState(() {
      isres = false;
    });
    Get.offAndToNamed("/home", arguments: 1);
  }

  Future<void> initData() async {
    List<Widget> tempWidget = [];
    Widget mylikesWidget = Container();
    if (SpUtil.getBool(SetKey.OPEN_ALIDRIVE)!) {
      bool refreshToken = await AliClient.refreshToken();
      if (refreshToken) {
        //我喜欢的歌曲音乐信息
        Map<String,dynamic> mylikealimusicdata;
        //我喜欢的音乐总个数
        int mylikesize = 0;
        List topnamelist = [];
        Widget playlistwidget;
        int topnamelistindex = 0;
        if(SpUtil.getObject(SetKey.ALI_MUSICDIR)!.isEmpty){
          OtherUtils.showToast("未发现歌单正在初始化请稍等。。。");
          refresh();
        }



        //获取用户信息
        //云盘名称
        setState(() {
          nick_name = SpUtil.getString(SetKey.ALI_NICK_NAME)!;
          avatar = ExtendedImage.network(SpUtil.getString(SetKey.ALI_AVATAR)!,height: size!.height * 0.5,);
        });
        //头像
        // aliusernfo["avatar"]
        // //用户名称
        // aliusernfo["user_name"]
        //没啥用
        // aliusernfo["phone"]

//          获取信息完毕
        for (var alidirname in SpUtil.getObject(SetKey.ALI_MUSICDIR)!.keys) {
          //判断是不是我喜欢的歌曲(我喜欢的歌曲不能添加)
          if (alidirname == "我喜欢的歌曲") {
            mylikealimusicdata = controller.aliPlayList.value[(SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname])];
            mylikesize = mylikealimusicdata.length;
            if (mylikesize > 0 && mylikesize < 4) {
              mylikealimusicdata.forEach((key, value) {
                topnamelist.add(mylikealimusicdata[key]);

              });
              //显示第一个
              //整理封面图
              setState(() {
                mylikesimages = ExtendedImage.network(topnamelist[0]["image"]["download_url"],headers: {
                  'Authorization': 'Bearer ' + AliClient.authorization,
                  "Referer": "https://www.aliyundrive.com/",
                  "RANGE": "bytes=0-${topnamelist[0]["image"]["size"]}"
                },
                    height: size!.height * 0.07);
              });
            } else if (mylikesize > 3) {
              for (var item in mylikealimusicdata.keys) {
                topnamelist.add(mylikealimusicdata[item]);
                topnamelistindex++;

                if (topnamelistindex == 4) {
                  topnamelistindex=0;
                 break;
                }
              }
              //显示TOP4
              setState(() {
                mylikesimages = Column(
                  children: [
                    Row(
                      children: [
                ExtendedImage.network(topnamelist[0]["image"]["download_url"],headers: {
                  'Authorization': 'Bearer ' + AliClient.authorization,
                  "Referer": "https://www.aliyundrive.com/",
                  "RANGE": "bytes=0-${topnamelist[0]["image"]["size"]}"
                }
                    ,height: size!.height * 0.03),
                        ExtendedImage.network(topnamelist[1]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[1]["image"]["size"]}"
                        },height: size!.height * 0.03),
                      ],
                    ),
                    Row(
                      children: [
                        ExtendedImage.network(topnamelist[2]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[2]["image"]["size"]}"
                        },height: size!.height * 0.03),
                        ExtendedImage.network(topnamelist[3]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[3]["image"]["size"]}"
                        },height: size!.height * 0.03),
                      ],
                    ),
                  ],
                );
              });
            } else {
              //显示默认
              setState(() {
                mylikesimages = GFAvatar(
                    // size: size.height*0.03,
                    backgroundImage: AssetImage("assets/no_music.jpg"),
                    shape: GFAvatarShape.square);
              });
            }
            //处理数据
            mylikesWidget = GFListTile(
                onTap: () {
                  if(mylikesize==0){
                    //没有歌曲
                    OtherUtils.showToast("无歌曲请添加后再进入");
                  }else{
                    //我喜欢的
                    Get.toNamed("/alidriveplaylist",arguments: SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname]);
                    // alidriveplaylist
                  }
                },
                avatar: mylikesimages,
                titleText: alidirname,
                subTitleText: '共计' + mylikesize.toString() + '首歌',
                icon: Icon(LineIcons.angleRight));
          } else {
            //其他歌单
            mylikealimusicdata = controller.aliPlayList.value[(SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname])];
            mylikesize = mylikealimusicdata.length;
            if (mylikesize > 0 && mylikesize < 4) {
              mylikealimusicdata.forEach((key, value) {
                topnamelist.add(mylikealimusicdata[key]);
                  return;
              });

              //显示第一个
              //整理封面图
              setState(() {
                mylikesimages =
                    ExtendedImage.network(topnamelist[0]["image"]["download_url"],headers: {
                      'Authorization': 'Bearer ' + AliClient.authorization,
                      "Referer": "https://www.aliyundrive.com/",
                      "RANGE": "bytes=0-${topnamelist[0]["image"]["size"]}"
                    },height: size!.height * 0.07);
              });
            } else if (mylikesize > 3) {

              mylikealimusicdata.forEach((key, value) {
                topnamelist.add(mylikealimusicdata[key]);
                topnamelistindex++;
                if (topnamelistindex == 4) {
                  return;

                }
              });
              //显示TOP4
              setState(() {
                mylikesimages = Column(
                  children: [
                    Row(
                      children: [
                ExtendedImage.network(topnamelist[0]["image"]["download_url"],headers: {
                  'Authorization': 'Bearer ' + AliClient.authorization,
                  "Referer": "https://www.aliyundrive.com/",
                  "RANGE": "bytes=0-${topnamelist[0]["image"]["size"]}"
                },height: size!.height * 0.03),
                        ExtendedImage.network(topnamelist[1]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[1]["image"]["size"]}"
                        }),
                      ],
                    ),
                    Row(
                      children: [
                        ExtendedImage.network(topnamelist[2]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[2]["image"]["size"]}"
                        },height: size!.height * 0.03),
                        ExtendedImage.network(topnamelist[3]["image"]["download_url"],headers: {
                          'Authorization': 'Bearer ' + AliClient.authorization,
                          "Referer": "https://www.aliyundrive.com/",
                          "RANGE": "bytes=0-${topnamelist[3]["image"]["size"]}"
                        },height: size!.height * 0.03),
                      ],
                    ),
                  ],
                );
              });
            } else {
              //显示默认
              setState(() {
                mylikesimages = GFAvatar(
                    // size: size.height*0.03,
                    backgroundImage: AssetImage("assets/no_music.jpg"),
                    shape: GFAvatarShape.square);
              });
            }
              //处理数据
              tempWidget.add(
                Slidable(
                  child: GFListTile(
                      onTap: () {
                        if(mylikesize==0){
                          //没有歌曲
                          print("无歌曲请添加后再进入");
                        }else{
                          Get.toNamed("/alidriveplaylist",arguments: SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname]);
                        }
                      },
                      avatar: mylikesimages,
                      titleText: alidirname,
                      subTitleText: '共计' + mylikesize.toString() + '首歌',
                      icon: Icon(LineIcons.angleRight)),
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (s) {
                          inputvalue = alidirname;
                          Alert(
                              style: AlertStyle(
                                  // backgroundColor: MyColors.MainBackgroundColor,
                                  // titleStyle: TextStyle(color: Colors.white)
                                  ),
                              context: context,
                              title: "修改歌单",
                              content: Column(
                                children: <Widget>[
                                  TextField(
                                    decoration: InputDecoration(
                                        // icon: Icon(Icons.account_circle),
                                        // labelText: 'Username',
                                        ),
                                    onChanged: (value) {
                                      inputvalue = value;
                                    },
                                  ),
                                  // TextField(
                                  //   obscureText: true,
                                  //   decoration: InputDecoration(
                                  //     icon: Icon(Icons.lock),
                                  //     labelText: 'Password',
                                  //   ),
                                  // ),
                                ],
                              ),
                              buttons: [
                                DialogButton(
                                    color: Colors.transparent,
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text(
                                      "取消",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 20),
                                    )),
                                DialogButton(
                                  color: Colors.transparent,
                                  onPressed: () {
                                    if (inputvalue != null) {
                                      Get.back();
                                      AliClient.rename(
                                        SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname],
                                              inputvalue)
                                          .then((value) => {refresh()});
                                    } else {
                                      OtherUtils.showToast("请输入歌单名称");
                                    }
                                  },
                                  child: Text(
                                    "确定",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
                                  ),
                                )
                              ]).show();
                        },
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: LineIcons.editAlt,
                        label: '修改',
                      ),
                      SlidableAction(
                        onPressed: (s) {
                          Alert(
                              context: context,
                              style: AlertStyle(
                                  // backgroundColor: MyColors.MainBackgroundColor,
                                  // titleStyle: TextStyle(color: Colors.white)
                                  ),
                              title: "是否删除该歌单",
                              buttons: [
                                DialogButton(
                                    color: Colors.transparent,
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: Text(
                                      "取消",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 20),
                                    )),
                                DialogButton(
                                  color: Colors.transparent,
                                  onPressed: () {
                                    Get.back();
                                    AliClient.delFile(
                                        SpUtil.getObject(SetKey.ALI_MUSICDIR)![alidirname])
                                        .then((value) => {refresh()});
                                  },
                                  child: Text(
                                    "确定",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 20),
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
                ),
              );
            }
          }
        }
        tempWidget.insert(0, mylikesWidget);
      body.value = Container(child: new ListView(children: tempWidget),);
      // Obx(()=>body);

      } else {
        OtherUtils.showToast("您的云盘登录信息,已经失效请重新登录。");
        SpUtil.remove(SetKey.REFRESH_TOKEN);
      }
    }
  // }
}
