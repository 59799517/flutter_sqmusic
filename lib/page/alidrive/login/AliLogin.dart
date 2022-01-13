import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/page/alidrive/login/CustomFloatingActionButtonLocation.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:webview_flutter/webview_flutter.dart';


///2022/1/13
///
class AliLogin extends StatefulWidget {
  const AliLogin({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AliLogin();
}

class _AliLogin extends State<AliLogin> {
  Size? size;
  AliDriveController alicontroller = Get.find<AliDriveController>();

  WebViewController? _controller;
  String _result="null";
  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    // FlutterWebviewPlugin flutterWebviewPlugin = new FlutterWebviewPlugin();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: WebView(
              initialUrl: "https://www.aliyundrive.com/sign/in",
                javascriptMode:JavascriptMode.unrestricted,
                onWebViewCreated:(controller){
                  _controller = controller;
                },
              onPageFinished: (url) {

                //调用JS得到实际高度
                _controller!.runJavascriptReturningResult("window.localStorage.getItem('token');").then((result){
                  if(result!="null"){
                    try {
                      _result=result;
                      var encode = json.decode(json.decode(result));
                      SpUtil.putString(SetKey.REFRESH_TOKEN, encode["refresh_token"])!.then((value) => {
                        OtherUtils.showToast("获取成功，开始刷新数据"),
                        alicontroller.RefresPlayListAllnfo().then((value) => {
                        Get.offAndToNamed("/home",arguments: 0)
                        })
                      });
                    } catch (e) {
                      print(e);
                    }
                  }
                }
                );
              },

            )
        ),
        floatingActionButton: Column(
          children: [FloatingActionButton(
            onPressed: (){
              _controller!.loadUrl("https://www.aliyundrive.com/sign/in");
            },
            tooltip: '重新加载',
            child: const Icon(Icons.refresh),
          ),
            SizedBox(height: 20,),
            FloatingActionButton(
              onPressed: (){
                Get.back();
              },
              tooltip: '关闭页面',
              child: const Icon(Icons.close),
            ),
            SizedBox(height: 20,),
            FloatingActionButton(
              onPressed: (){
                try {
                  var encode = json.decode(json.decode(_result));
                  if(encode["refresh_token"]!="null"){
                                    SpUtil.putString(SetKey.REFRESH_TOKEN, encode["refresh_token"])!.then((value) => {
                                      OtherUtils.showToast("获取成功，开始刷新数据"),
                                      alicontroller.RefresPlayListAllnfo().then((value) => {
                                        Get.offAndToNamed("/home",arguments: 0)
                                        })
                                    });

                                  }else{
                                    OtherUtils.showToast("数据获取失败，重新登录");
                                  }
                } catch (e) {
                  OtherUtils.showToast("数据获取失败，重新登录");
                }
              },
              tooltip: '获取成功',
              child: const Icon(Icons.check),
            )],
        ),
        floatingActionButtonLocation: CustomFloatingActionButtonLocation(FloatingActionButtonLocation.endFloat,0,size!.height*0.7),
    );
  }

  @override
  void initState() {
    // _controller.
    Future.delayed(Duration.zero, () {
      initData();
    });
  }

  void initData() async {

  }
}