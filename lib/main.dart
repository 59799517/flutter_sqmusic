// @dart=2.9
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqmusic/controller/ControllerInjec.dart';
import 'package:sqmusic/route/MainRoute.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/MusicCach.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  /// 初始化 Hive
  await DBUtil.install();
  // await DBUtil.getInstance();
  //依赖注入
  ControllerInjec().injec();
  MusicCach.initDirectory();
  runApp(MainRoute().getMaterialApp());
  // runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     // String id ="156483846";
//     // String s = "user=e3cc098fd4c59ce2&android_id=e3cc098fd4c59ce2&prod=kwplayer_ar_9.3.1.3&corp=kuwo&newver=2&vipver=9.3.1.3&source=kwplayer_ar_9.3.1.3_qq.apk&p2p=1&notrace=0&type=convert_url2&br=1000kape&format=flac|mp3|aac&sig=0&rid="+ id +"&priority=bitrate&loginUid=435947810&network=WIFI&loginSid=1694167478&mode=download&uid=658048466";
//     // var encode = utf8.encode(s);
//     // var encrypt2 = KuwoDES.encrypt2(encode, encode.length, KuwoDES.SECRET_KEY, KuwoDES.SECRET_KEY.length);
//     // var encode1 = Base64Coder.encode1(encrypt2, encrypt2.length);
//     // String outstr = "";
//     // for (String o in encode1) {
//     //   outstr+=o;
//     // }
//     // print(outstr);
//     // API.search("星晴").then((data)=>{
//     //  if(data.statusCode==200){
//     //    json.decode(data.data)["abslist"][0]["MUSICRID"].toString().split("_")[1],
//     //    print(json.decode(data.data)[0])
//     //  }else{
//     //    //todo 搜索请求错误
//     //  }
//     // });
//
//     // var c = "A".codeUnitAt(0);
//     // Characters c = Characters("A");
//     // String.fromCharCode(charCode)
//     // int cc =  c.hashCode;
//     // cc++;
//     // var string = String.fromCharCode(cc);
//     // print(string);
//
//   // var vp =   VideoPlayerController.asset("file/456.flac");
//   // vp.play();
//    //
//    //  final player = AudioPlayer();
//    // player.setAsset('file/qhc.APE');
//    //  player.play();
//
//     // var audio = Audio(
//     //   'file/456.flac',
//     //   //playSpeed: 2.0,
//     //   // metas: Metas(
//     //   //   id: 'Rock',
//     //   //   title: 'Rock',
//     //   //   artist: 'Florent Champigny',
//     //   //   album: 'RockAlbum',
//     //   //   image: MetasImage.network(
//     //   //       'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
//     //   // ),
//     // );
//     //
//     // AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.withId("sqmusic");
//     // _assetsAudioPlayer.open(audio, autoStart: true,
//     //   showNotification: true,);
//
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
