import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:blur/blur.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:crypto/crypto.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/%20steam/MusicSteam.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'dart:convert';

import 'package:sqmusic/controller/MusicPlayController.dart';
import 'package:sqmusic/lyric/lyric_controller.dart';
import 'package:sqmusic/lyric/lyric_util.dart';
import 'package:sqmusic/lyric/lyric_widget.dart';
import 'package:sqmusic/page/music/widge/music_play_Image_widge.dart';
import 'package:sqmusic/set/PlaySongQuality.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:sqmusic/widget/BlurryContainer.dart';
import 'package:sqmusic/widget/FLListTile.dart';

class PlayMusicPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayMusicPage();
}

class _PlayMusicPage extends State<StatefulWidget>
    with TickerProviderStateMixin {
  String musicname = "加载中。。。";
  String artist = "";

  //歌曲信息
  dynamic songdata;

  //播放状态(默认是暂停)
  int playType = 0;

  //添加到我喜欢的歌单中
  var isLike = false.obs;

  //喜欢图标
  Icon isLikeIcon = Icon(LineIcons.heart);

  //播放总时长
  var playDuration = Duration(seconds: 0).obs;

  //当前正在播放歌曲的时间
  var nowplayDuration = Duration(seconds: 0).obs;

  //播放器时间化工具
  DateFormat _dateFormat = DateFormat('mm:ss');

  // //  歌曲播放模式(默认初始化时会根据播放器自动修改)
  // int loopicon =0;
  //是显示歌词还是图片(默认显示图片)
  var isshowimage = true.obs;
  List<Widget> image = [];

  //是否加载重要组件防止页面初始化未完成就开始渲染（等歌曲信息初始化完成后在进行展示）
  bool isshow = false;
  MusicPlayController controller = Get.find<MusicPlayController>();
  KuwoController kugwocontroller = Get.find<KuwoController>();
  AliDriveController aliDriveController = Get.find<AliDriveController>();
  LyricController? _lyricController;

  Size? size;
  Widget imageWidget = Image.asset("assets/no_music.jpg", fit: BoxFit.cover);

  //  歌曲播放模式
  var loopint = 1.obs;

// 播放状态图标(默认暂停状态)
  var playStatus = Icon(
    LineIcons.play,
  ).obs;

//循环模式图标
  var loopStatus = Icon(LineIcons.alternateRedo).obs;

  //歌词信息
  List<dynamic> Lyricvalue = [{
    "lineLyric": "暂无歌词",
    "time": "0.0"
  }];



  //图标库
  //随机歌曲
  // Icon(LineIcons.random)
  //单曲播放
  //  Icon(Icons.repeat_one)
  //列表循环
  // Icon(LineIcons.alternateRedo),
  //暂停
  // Icon(LineIcons.pause,)

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body:
            //整体进行模糊化处理
            Blur(
          blur: 50,
          blurColor: isshowimage.value?Colors.white:Colors.black,
          colorOpacity: 0.2,
          child: Container(
            width: size!.width,
            height: size!.height,
            child: imageWidget,
          ),
          overlay: Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 21,
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: Obx(()=>Expanded(
                            flex: isshowimage.value?30:1,
                            child:Container(
                                height: isshowimage.value?size!.height:0,
                                width: isshowimage.value?size!.width:0,
                                // color: Colors.green,
                                child:
                                Column(
                                  children: [
                                    //顶部返回与歌手
                                    Container(
                                        child: Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                              children: [
                                                //返回按钮
                                                Container(
                                                    child: IconButton(
                                                      icon: Icon(
                                                        LineIcons.arrowLeft,
                                                        size: 30,
                                                      ),
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                    )),
                                                //歌曲名称
                                                Container(),
                                                //更多设置等功能
                                                Container(
                                                  child: Icon(LineIcons.memory),
                                                )
                                              ],
                                            ),
                                            color: Colors.transparent,
                                          ),
                                        )),

                                    //歌曲图片

                                    Expanded(
                                      flex: 9,
                                      child: InkWell(
                                        child: Container(
                                          child: imageWidget,
                                          color: Colors.transparent,
                                        ),
                                        onTap: (){
                                          isshowimage.value=false;
                                        },
                                      ),
                                    ),

                                    //间隔条
                                    Container(
                                      child: Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                    ),
                                    //歌曲名称
                                    Container(
                                        child: Expanded(
                                          flex: 3,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  musicname,
                                                  style: TextStyle(fontSize: 25),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  artist,
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),


                                    //间隔条
                                    Container(
                                      child: Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: isLikeIcon,
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              if (isopenalidrive()) {
                                                //判断当前是不是正喜欢的
                                                if (isLike.value) {
                                                  //需要取消喜欢
                                                  isLike.value = false;
                                                  //修改图标
                                                  setState(() {
                                                    isLikeIcon =
                                                        Icon(LineIcons.heart);
                                                  });
                                                  deltoalidrive("我喜欢的歌曲")
                                                      .then((value) => {
                                                    //刷新歌单
                                                    AliClient
                                                        .RefresPlayListByNameInfo(
                                                        "我喜欢的歌曲"),
                                                    aliDriveController
                                                        .RefresPlayListByNameInfo(
                                                        "我喜欢的歌曲")
                                                  });
                                                } else {
                                                  //标记为喜欢的
                                                  isLike.value = true;
                                                  //修改图标
                                                  setState(() {
                                                    isLikeIcon = Icon(
                                                      LineIcons.heart,
                                                      color: Colors.red,
                                                    );
                                                  });
                                                  uploadtoalidrive("我喜欢的歌曲")
                                                      .then((value) => {
                                                    //添加失败
                                                    if (!value)
                                                      {
                                                        isLike.value =
                                                        false,
                                                        setState(() {
                                                          isLikeIcon = Icon(
                                                              LineIcons
                                                                  .heart);
                                                        })
                                                      }
                                                    else
                                                      {
                                                        //刷新歌单
                                                        aliDriveController
                                                            .RefresPlayListByNameInfo(
                                                            "我喜欢的歌曲")
                                                            .then(
                                                                (value) =>
                                                            {})
                                                      }
                                                  });
                                                }
                                              } else {
                                                OtherUtils.showToast(
                                                    "请打开云盘功能后使用。");
                                              }
                                            },
                                          ),
                                          Obx(() => IconButton(
                                            icon: loopStatus.value,
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              loopint++;
                                              loopint.value =
                                                  loopint.value % 3;
                                              controller.assetsAudioPlayer!
                                                  .setLoopMode(
                                                  LoopMode.values[
                                                  loopint.value]);
                                              OtherUtils.showToast(
                                                  loopint.value == 0
                                                      ? "随机播放"
                                                      : loopint.value == 1
                                                      ? "单曲循环"
                                                      : "列表循环");
                                              SpUtil.putInt(
                                                  SetKey.PLAY_SONG_LOOP,
                                                  loopint.value);
                                            },
                                          )),
                                          IconButton(
                                            icon: Icon(Ionicons
                                                .file_tray_full_outline),
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              String groupid = "";
                                              var groupValue = 0.obs;
                                              var groupvaluenamelist = {};
                                              if (isopenalidrive()) {
                                                Alert(
                                                    context: context,
                                                    title: "添加至歌单",
                                                    content: StatefulBuilder(
                                                        builder: (context,
                                                            wpsetState) {
                                                          //添加到歌单的列表
                                                          List<Widget>
                                                          playListWidget = [];
                                                          int group = 0;
                                                          for (var playname in SpUtil
                                                              .getObject(SetKey
                                                              .ALI_MUSICDIR)!
                                                              .keys) {
                                                            if (playname ==
                                                                "我喜欢的歌曲") {
                                                              continue;
                                                            }
                                                            groupvaluenamelist[
                                                            group] = playname;
                                                            playListWidget
                                                                .add(Container(
                                                              height: 50,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                                children: [
                                                                  Text(playname),
                                                                  GFRadio(
                                                                      size: GFSize
                                                                          .SMALL,
                                                                      type: GFRadioType
                                                                          .custom,
                                                                      activeIcon:
                                                                      Icon(
                                                                        LineIcons
                                                                            .check,
                                                                        color: GFColors
                                                                            .SUCCESS,
                                                                      ),
                                                                      value: group,
                                                                      groupValue:
                                                                      groupValue
                                                                          .value,
                                                                      onChanged:
                                                                          (value) {
                                                                        print(groupValue
                                                                            .value);
                                                                        wpsetState(
                                                                                () {
                                                                              groupValue
                                                                                  .value =
                                                                                  int.parse(
                                                                                      value.toString());
                                                                            });
                                                                      },
                                                                      inactiveIcon:
                                                                      null,
                                                                      activeBorderColor:
                                                                      GFColors
                                                                          .SUCCESS,
                                                                      // activeBgColor:Colors.transparent,
                                                                      radioColor:
                                                                      GFColors
                                                                          .WARNING,
                                                                      customBgColor:
                                                                      GFColors
                                                                          .SUCCESS,
                                                                      // inactiveBgColor:Colors.grey,
                                                                      inactiveBorderColor:
                                                                      Colors
                                                                          .grey),
                                                                ],
                                                              ),
                                                            ));

                                                            group++;
                                                          }

                                                          return Column(
                                                            children:
                                                            playListWidget,
                                                          );
                                                        }),
                                                    buttons: [
                                                      DialogButton(
                                                        onPressed: () =>
                                                            Get.back(),
                                                        child: Text(
                                                          "取消",
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      DialogButton(
                                                        onPressed: () {
                                                          Get.back();
                                                          //查看是否有该歌曲
                                                          Map data = aliDriveController
                                                              .aliPlayList
                                                              .value[SpUtil
                                                              .getObject(SetKey
                                                              .ALI_MUSICDIR)![
                                                          groupvaluenamelist[
                                                          groupValue
                                                              .value]]];
                                                          if (data.containsKey(
                                                              musicname +
                                                                  " - " +
                                                                  artist)) {
                                                            //有该歌曲
                                                            OtherUtils
                                                                .showToast(
                                                                "歌曲已经存在");
                                                          } else {
                                                            uploadtoalidrive(
                                                                groupvaluenamelist[
                                                                groupValue
                                                                    .value])
                                                                .then(
                                                                    (value) => {
                                                                  aliDriveController.RefresPlayListByNameInfo(groupvaluenamelist[groupValue.value]).then((value) =>
                                                                  {})
                                                                });
                                                          }
                                                        },
                                                        child: Text(
                                                          "确定",
                                                          style: TextStyle(
                                                              color:
                                                              Colors.white,
                                                              fontSize: 20),
                                                        ),
                                                      )
                                                    ]).show();
                                              } else {
                                                OtherUtils.showToast(
                                                    "请打开云盘功能后使用。");
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                                LineIcons.alternateListAlt),
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              showCupertinoModalBottomSheet(
                                                  context: context,
                                                  expand: false,
                                                  builder: (context) =>
                                                      BlurryContainer(
                                                          blur: 50,
                                                          width:
                                                          size!.width * 0.8,
                                                          // blurColor: Colors.red,
                                                          // colorOpacity: 0.2,
                                                          child: ListView
                                                              .separated(
                                                            // scrollDirection: Axis.vertical,
                                                              scrollDirection: Axis
                                                                  .vertical,
                                                              shrinkWrap:
                                                              true,
                                                              padding:
                                                              EdgeInsets.only(
                                                                  top:
                                                                  0),
                                                              itemBuilder:
                                                                  (context,
                                                                  item) {
                                                                return Container(
                                                                  // width: 1000,
                                                                  // height: 10000,
                                                                  color: Colors
                                                                      .transparent,
                                                                  child:
                                                                  FLListTile(
                                                                    isThreeLine:
                                                                    false,
                                                                    backgroundColor:
                                                                    Colors.transparent,
                                                                    leading:
                                                                    ExtendedImage.network(
                                                                      controller
                                                                          .assetsAudioPlayer!
                                                                          .playlist!
                                                                          .audios[item]
                                                                          .metas
                                                                          .image!
                                                                          .path,
                                                                      cache:
                                                                      true,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    ),

                                                                    // ImageUtils.Base64toImage(_records[item]['musicImage']),
                                                                    title:
                                                                    new Text(
                                                                      controller
                                                                          .assetsAudioPlayer!
                                                                          .playlist!
                                                                          .audios[item]
                                                                          .metas
                                                                          .title!,
                                                                      style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                        20,
                                                                      ),
                                                                    ),
                                                                    subtitle: Align(
                                                                        child: new Text(
                                                                          controller.assetsAudioPlayer!.playlist!.audios[item].metas.artist!,
                                                                          // style: TextStyle(
                                                                          //     color: Colors.white54),
                                                                        ),
                                                                        alignment: FractionalOffset.topLeft),
                                                                    trailing:
                                                                    new Icon(
                                                                      Icons
                                                                          .keyboard_arrow_right,
                                                                      // color: Colors.white,
                                                                    ),
                                                                    onTap:
                                                                        () {
                                                                      controller
                                                                          .assetsAudioPlayer!
                                                                          .playlistPlayAtIndex(item)
                                                                          .then((value) => {
                                                                        setState(() {
                                                                          musicname = controller.assetsAudioPlayer!.current.value!.audio.audio.metas.title!;
                                                                          artist = controller.assetsAudioPlayer!.current.value!.audio.audio.metas.artist!;
                                                                          imageWidget = ExtendedImage.network(
                                                                            controller.assetsAudioPlayer!.current.value!.audio.audio.metas.image!.path,
                                                                            fit: BoxFit.fill,
                                                                            cache: true,
                                                                          );
                                                                        })
                                                                      });
                                                                      Get.back();
                                                                      // playInfo.addAudio(_records[item], false);
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                              separatorBuilder:
                                                                  (BuildContext context, int index) =>
                                                              new Divider(
                                                                color:
                                                                Colors.transparent,
                                                              ),
                                                              itemCount: controller
                                                                  .assetsAudioPlayer!
                                                                  .playlist!
                                                                  .audios
                                                                  .length)));
                                            },
                                          )
                                        ],
                                      ),
                                    ),

                                  ],
                                )
                            )
                            ,
                            //over
                          )),
                        ),
                        Container(
                          // color: Colors.red,
                          child: Obx(()=>Expanded(
                            flex: isshowimage.value?1:30,
                            child:Container(
                              height: isshowimage.value?0:size!.height,
                              width: isshowimage.value?0:size!.width,
                              child: InkWell(
                                child: Container(
                                  height: isshowimage.value?0:size!.height,
                                  width: isshowimage.value?0:size!.width,
                                  child:  LyricWidget(
                                    enableDrag:false,
                                    lyricStyle: TextStyle(
                                      color: isshowimage.value?Colors.transparent:Colors.white24,
                                      fontSize: 17,
                                    ),
                                    currLyricStyle: TextStyle(
                                        color: isshowimage.value?Colors.transparent:Colors.white, fontSize: isshowimage.value?0:23),
                                    draggingRemarkLyricStyle: TextStyle(color: Colors.transparent),
                                    // draggingLyricStyle: TextStyle(color: Colors.white24),
                                    controller: _lyricController,
                                    size: isshowimage.value?Size(0,0):Size(size!.width, size!.height * 0.48),
                                    lyrics: LyricUtil.formatLyricByKuwo(Lyricvalue),
                                    // currentProgress: nowtime
                                    //     .value.inMilliseconds
                                    //     .toDouble(),
                                  ),
                                ),
                                onTap: (){
                                  isshowimage.value=true;
                                },
                              ),
                            ),
                          ))
                          ,
                        ),

                        //暂停播放等操作模块
                        Container(
                            child: Expanded(
                              flex: 6,
                              child: Container(
                                child: Column(
                                  children: [
                                    //上半部分功能
                                    //播放条
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Obx(() => Text(controller
                                                  .MuisicDurationtoString(
                                                      nowplayDuration.value))),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Container(
                                              child: SliderTheme(
                                                data: SliderThemeData(
                                                    trackHeight: 2),
                                                child: Obx(() => Slider(
                                                    max: playDuration
                                                        .value.inMicroseconds
                                                        .toDouble(),
                                                    min: 0.0,
                                                    inactiveColor: Colors.grey,
                                                    // divisions: 100,
                                                    activeColor: Colors.black38,
                                                    // inactiveColor: Colors.yellow,
                                                    value: nowplayDuration
                                                        .value.inMicroseconds
                                                        .toDouble(),
                                                    onChanged: (double v) {
                                                      nowplayDuration.value =
                                                          new Duration(
                                                              microseconds:
                                                                  v.toInt());
                                                    },
                                                    onChangeStart:
                                                        (double startValue) {
                                                      print(
                                                          'Started change at $startValue');
                                                    },
                                                    onChangeEnd:
                                                        (double newValue) {
                                                      controller.seek(Duration(
                                                          microseconds: newValue
                                                              .toInt()));
                                                      print(
                                                          'Ended change on $newValue');
                                                    },
                                                    semanticFormatterCallback:
                                                        (double newValue) {
                                                      return '${newValue.round()} dollars';
                                                    })),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Obx(() => Text(controller
                                                  .MuisicDurationtoString(
                                                      playDuration.value))),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    //下半部分功能区
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              LineIcons.stepBackward,
                                              // color: Colors.white,
                                            ),
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              controller.assetsAudioPlayer!
                                                  .previous();
                                            },
                                          ),
                                          Obx(() => IconButton(
                                                icon: playStatus.value,
                                                iconSize: size!.height * 0.05,
                                                onPressed: () {
                                                  controller.assetsAudioPlayer!
                                                          .isPlaying.value
                                                      ? controller.pauseAudio()
                                                      : controller.playAudio();
                                                },
                                              )),
                                          IconButton(
                                            icon: Icon(LineIcons.stepForward
                                                // color: Colors.white,
                                                ),
                                            iconSize: size!.height * 0.05,
                                            onPressed: () {
                                              controller.nextmusic();
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void initState() {
    //歌词组件注册
    _lyricController = LyricController(vsync: this,);


    Future.delayed(Duration.zero, () {
      //不用播放新歌曲打开即可
      if (Get.arguments == null) {
        //开始监听播放状态
        listenPlayMusic();
      } else {
        if (Get.arguments["refresh"]) {


          if (Get.arguments["isdrive"]) {
            //云盘
            controller
                .newAddAudio(
                    songinfo: Get.arguments["data"]["data"]["songinfo"],
                    playurl: Get.arguments["data"]["playurl"],
                    suffix: Get.arguments["data"]["suffix"],
                    songSource: Get.arguments["songSource"],
                    driveinfo: Get.arguments["dirveinfo"],
                    data: Get.arguments["data"],
                    isdrive: true)
                .then((openmusic) => {
                      songdata = Get.arguments["data"],
                      //开始监听播放状态
                      listenPlayMusic()
                    });
          } else {
            kugwocontroller
                .songInfo(musicId: Get.arguments["id"])
                .then((value) => {
                      //歌曲详情
                      kugwocontroller
                          .playUrl(
                              musicId: Get.arguments["id"],
                              brvalue:
                                  SpUtil.getString(SetKey.PLAY_SONG_QUALITY)!)
                          .then((musicplayurl) => {
                                //获取下载链接
                                value["playurl"] = musicplayurl
                                    .toString()
                                    .split("\n")[2]
                                    .split("=")[1]
                                    .split("\r")[0],
                                value["suffix"] =
                                    ".${musicplayurl.toString().split("\n")[0].split("=")[1].split("\r")[0]}",
                                controller
                                    .newAddAudio(
                                        songinfo: value["data"]["songinfo"],
                                        playurl: musicplayurl
                                            .toString()
                                            .split("\n")[2]
                                            .split("=")[1]
                                            .split("\r")[0],
                                        suffix:
                                            ".${musicplayurl.toString().split("\n")[0].split("=")[1].split("\r")[0]}",
                                        songSource: Get.arguments["songSource"],
                                data: value)
                                    .then((openmusic) => {
                                          songdata = value,
                                          //开始监听播放状态
                                          listenPlayMusic()
                                        })
                              })
                    });
          }
        } else {
          listenPlayMusic();
        }
      }

      // initData();
    });
  }

  void initData() async {}

  listenPlayMusic() {
    //加载歌词
    // var formatLyricByKuwo = LyricUtil.formatLyricByKuwo(Lyricvalue);
    // print(formatLyricByKuwo);
    // Lyricvalue=songdata["data"]["lrclist"];
    //监听歌曲播放信息
    controller.assetsAudioPlayer!.current.listen((event) {
      setState(() {
        Lyricvalue=LyricUtil.Lyrics[event!.audio.audio.metas.id];
        musicname = event.audio.audio.metas.title!;
        artist = event.audio.audio.metas.artist!;
        imageWidget = ExtendedImage.network(
          event.audio.audio.metas.image!.path,
          fit: BoxFit.fill,
          cache: true,
        );
      });


      // playurl.value = event.audio.audio.path;
      playDuration.value = event!.audio.duration;

      // audiopath.value = event.audio.audio.path;
      //加载歌词等信息
      // WidgetsBinding.instance.addPostFrameCallback((_) => oninit());
      islikesong();
    });

    // 监听歌曲播放信息 （正在播放的歌曲时长等操作）
    controller.assetsAudioPlayer!.currentPosition.listen((event) {
      if (controller.assetsAudioPlayer!.currentPosition.hasValue) {

        try {
          nowplayDuration.value = event;
          _lyricController!.progress = nowplayDuration.value;
        } catch (e) {
          _lyricController!.progress =Duration(seconds: 0);
        }
      }
    });
    //监听当前播放状态（暂停等操作）
    controller.assetsAudioPlayer!.isPlaying.listen((event) {
      if (controller.assetsAudioPlayer!.isPlaying.hasValue) {
        if (controller.assetsAudioPlayer!.isPlaying.value) {
          //播放状态
          playStatus.value = Icon(
            LineIcons.pause,
          );
        } else {
          //暂停状态
          playStatus.value = Icon(
            LineIcons.play,
          );
        }
      }
    });
    //监听 歌曲循环状态
    controller.assetsAudioPlayer!.loopMode.listen((event) {
      if (controller.assetsAudioPlayer!.loopMode.hasValue) {
        loopint.value = controller.assetsAudioPlayer!.loopMode.value.index;
        loopStatus.value =
            controller.assetsAudioPlayer!.loopMode.value.index == 0
                ? Icon(
                    LineIcons.random,
                  )
                : controller.assetsAudioPlayer!.loopMode.value.index == 1
                    ? Icon(Icons.repeat_one)
                    : Icon(LineIcons.alternateRedo);
      }
    });
  }

  //验证是否真正打开了云盘功能
  bool isopenalidrive() {
    if (SpUtil.getBool(SetKey.OPEN_ALIDRIVE)!) {
      return SpUtil.containsKey(SetKey.REFRESH_TOKEN)!;
    }
    return false;
  }

  //上传歌曲到云盘
  Future<bool> uploadtoalidrive(String musicPlayName) async {
    return await AliClient.addSongToAliDrive(
        MusicInfo: songdata,
        file_id: SpUtil.getObject(SetKey.ALI_MUSICDIR)![musicPlayName]);
  }

  //删除云盘歌曲
  Future<bool> deltoalidrive(String musicPlayName) async {
    String object = SpUtil.getObject(SetKey.ALI_MUSICDIR)![musicPlayName];
    var s = musicname + " - " + artist;
    Map ssss = SpUtil.getObject(SetKey.ALI_MUSICDATA)![object];
    dynamic tepdata = ssss[s];
    return await AliClient.delSong(tepdata);
  }

  islikesong() {
    //判断是不是喜欢的歌曲
    String object = SpUtil.getObject(SetKey.ALI_MUSICDIR)!["我喜欢的歌曲"];
    var s = musicname + " - " + artist;
    Map ssss = SpUtil.getObject(SetKey.ALI_MUSICDATA)![object];
    isLike.value = ssss.containsKey(s);

    setState(() {
      if (isLike.value) {
        isLikeIcon = Icon(
          LineIcons.heart,
          color: Colors.red,
        );
      } else {
        isLikeIcon = Icon(LineIcons.heart);
      }
    });
  }

  tolyrcpage() {
    //转换到歌词播放页面
  }
}
