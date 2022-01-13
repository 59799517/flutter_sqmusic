import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqmusic/page/HomePage.dart';
import 'package:sqmusic/page/IndexPage.dart';
import 'package:sqmusic/page/alidrive/AliDrivePlayListPage.dart';
import 'package:sqmusic/page/alidrive/login/AliLogin.dart';
import 'package:sqmusic/page/kuwo/KuwoBangListPage.dart';
import 'package:sqmusic/page/kuwo/KuwoSearchListPage.dart';
import 'package:sqmusic/page/kuwo/widget/top_list_container.dart';
import 'package:sqmusic/page/music/PlayMusicPage.dart';
import 'package:sqmusic/page/set/CheckToken.dart';


/// 路由管理
class MainRoute {
  List<GetPage> routes = [
    new GetPage(name: '/', page: () => IndexPage()),
    new GetPage(name: '/index', page: () => IndexPage()),
    new GetPage(name: '/home', page: () => HomePage()),
    new GetPage(name: '/alidriveplaylist', page: () => AliDrivePlayListPage()),
    new GetPage(name: '/checktoken', page: () => CheckToken()),
    new GetPage(name: '/musicplay', page: () => PlayMusicPage()),
    // new GetPage(name: '/checklogin', page: () => CheckLoginPage()),
    new GetPage(name: '/kuwosearchlist', page: () => KuwoSearchListPage()),
    new GetPage(name: '/kuwobanglist' ,page: () => KuwoBangListPage()),
    new GetPage(name: '/alilogin' ,page: () => AliLogin()),
    // new GetPage(name: '/listdetailpage' ,page: () => ListDetailPage()),
    //
    // new GetPage(name: '/set', page: () => SetPage()),
    // new GetPage(name: '/musicplaylyric', page: () => MusicPlayLyric()),
  ];

  GetMaterialApp getMaterialApp() {
    DateTime lastPopTime; //上次点击时间
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);//隐藏状态栏，保留底部按钮栏
      SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    return GetMaterialApp(
        debugShowCheckedModeBanner:false,
        // unknownRoute: routes[6],
        initialRoute: '/',
        getPages:routes,
        routingCallback: (routing)
    {
      // if (routing.current == "/index") {
      //   if (lastPopTime == null ||
      //       DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
      //     //两次点击间隔超过1秒则重新计时
      //     lastPopTime = DateTime.now();
      //     Fluttertoast.showToast(
      //         msg: "再次返回退出",
      //         toastLength: Toast.LENGTH_SHORT,
      //         gravity: ToastGravity.BOTTOM,
      //         timeInSecForIosWeb: 1,
      //         backgroundColor: Colors.black,
      //         textColor: Colors.white,
      //         fontSize: 16.0);
      //     // Toast.show("再次返回退出", context);
      //     return new Future.value(false);
      //   } else {
      //     //判断是否需要缓存上一次的歌曲
      //     return new Future.value(true);
      //   }
      // }
    }
  );
}

}