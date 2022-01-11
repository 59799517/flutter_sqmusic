import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'package:sqmusic/controller/MusicPlayController.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/ToastUtil.dart';

///引导页面
///
class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IndexPage();
}

class _IndexPage extends State<IndexPage> {
  Size? size;
  MusicPlayController controller = Get.find<MusicPlayController>();
  AliDriveController aController = Get.find<AliDriveController>();
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
                child: Center(
                    child: Image.asset(
          "assets/guide.jpg",
          fit: BoxFit.cover,
          width: size!.width,
          height: size!.height,
        )))));
  }

  @override
  void initState() {
    //初始化歌曲列表


    // KuwoController kwcontroller = Get.find<KuwoController>();
    //  kwcontroller.bangMenu().then((value) => {
    //
    //  print(value)
    //
    //  });
    controller.init();
    Future.delayed(Duration.zero, () {
      initData();
    });
  }

  void initData() async {
    next();
  }

  void next() async {
    //判断是否第一次安装应用
    // bool isFirstInstall = DBUtil.firstApp();

    if (SpUtil.getBool(SetKey.OPEN_ALIDRIVE)!) {
      //打开了同步功能并且有token信息
      if (SpUtil.containsKey(SetKey.REFRESH_TOKEN)!) {
        bool refreshToken = await AliClient.refreshToken();
        if (refreshToken) {

          Get.offAndToNamed("/home");
          //刷新数据成功获取歌曲信息
          await aController.RefresPlayListAllnfo();
          // await AliClient.RefreshPlaylistInfo();
        } else {
          OtherUtils.showToast("您的云盘登录信息,已经失效请重新登录。");
          SpUtil.remove(SetKey.REFRESH_TOKEN);
          Get.offAndToNamed("/home");
        }
      } else {
        //没打开则清空阿里云参数（进行退出操作）
        OtherUtils.showToast("您的云盘登录信息,已经失效请重新登录。");
        SpUtil.remove(SetKey.REFRESH_TOKEN);
        Get.offAndToNamed("/home");
      }
      OtherUtils.showToast("获取到了刷新信息");
      Get.offAndToNamed("/home");
      //判断获取到的刷新信息对不对不对
    } else {
      //没有包含登录阿里云信息提示是否打开阿里云
      OtherUtils.showToast("如果想要使用云同步功能，需要在设置页面打开。");
      Get.offAndToNamed("/home");
    }

  }
}
