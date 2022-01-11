import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sqmusic/controller/MusicPlayController.dart';
import 'package:sqmusic/page/alidrive/AliDrivePage.dart';
import 'package:sqmusic/page/kuwo/KuWoHomePage.dart';
import 'package:sqmusic/page/set/SetPage.dart';
import 'package:sqmusic/utils/MyColors.dart';

///2022/1/5
///
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  Size? size;

  ///导航选择的当前对象
  int _NavIndex = 0;

  //导航选择图标
  List<IconData> _iconList = [
    Ionicons.home_outline,
    Ionicons.file_tray_full_outline,
    // Ionicons.musical_notes_outline,
    Ionicons.cog_outline,
    // Icons.code,
  ];

  //当前需要显示的页面内
  final List<Widget> _currents = [KuWoHomePage(), AliDrivePage(), SetPage()];
  MusicPlayController controller = Get.find<MusicPlayController>();

  String musicname = "";
  String artist = "";
  Widget imageWidget = Image.asset("assets/no_music.jpg", fit: BoxFit.cover);

  //播放总时长
  var playDuration = Duration(seconds: 0).obs;

  //当前正在播放歌曲的时间
  var nowplayDuration = Duration(seconds: 0).obs;
  var playStatus = Icon(
    LineIcons.play,
  ).obs;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return DoubleBack(
      message: "再次返回后退出",
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
              // width: size!.width,
              //   height: size!.height,
              child: Column(
                children: [
                  Expanded(
                    child: _currents[_NavIndex],
                    flex: 11,
                  ),
                  Container(
                    child: Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //首页图片
                            Expanded(
                                flex: 2,
                                child: InkWell(
                                  child: Container(
                                    child: imageWidget,
                                  ),
                                  onTap: () {
                                    if (musicname != "") {
                                      Get.toNamed("/musicplay",
                                          arguments: {"refresh": false});
                                    }
                                  },
                                )),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                            //中部文字
                            Expanded(
                              flex: 10,
                              child: InkWell(
                                child: Container(
                                    width: size!.width,
                                    child: Text(musicname + " - " + artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis)),
                                onTap: () {
                                  if (musicname != "") {
                                    Get.toNamed("/musicplay",
                                        arguments: {"refresh": false});
                                  }
                                },
                              ),
                            ),
                            //右侧控制按钮
                            Expanded(
                                flex: 2,
                                child: Obx(
                                      () => Container(
                                    child: IconButton(
                                      icon: playStatus.value,
                                      onPressed: () {
                                        controller.assetsAudioPlayer!.playOrPause();
                                      },
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
        bottomNavigationBar: AnimatedBottomNavigationBar(
          backgroundColor: Colors.grey[300],
          icons: _iconList,
          activeIndex: _NavIndex,
          gapLocation: GapLocation.none,
          notchSmoothness: NotchSmoothness.smoothEdge,
          // notchSmoothness: NotchSmoothness.defaultEdge,
          leftCornerRadius: 0,
          rightCornerRadius: 0,
          // backgroundColor: Colors.purple[200],
          // activeColor: Colors.purple[400],
          onTap: (index) {
            setState(() {
              _NavIndex = index;
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    if (Get.arguments != null) {
      _NavIndex = Get.arguments;
    }

    Future.delayed(Duration.zero, () {
      initData();
    });
  }

  void initData() async {
    listenPlayMusic();
  }

  listenPlayMusic() async {
    //监听歌曲播放信息
    controller.assetsAudioPlayer!.current.listen((event) {
      setState(() {
        musicname = event!.audio.audio.metas.title!;
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
    });
    // 监听歌曲播放信息 （正在播放的歌曲时长等操作）
    controller.assetsAudioPlayer!.currentPosition.listen((event) {
      if (controller.assetsAudioPlayer!.currentPosition.hasValue) {
        nowplayDuration.value = event;
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
    return null;
  }
}
