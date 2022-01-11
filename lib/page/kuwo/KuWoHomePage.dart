import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'package:sqmusic/page/kuwo/widget/top_list_container.dart';

///2022/1/5
///
class KuWoHomePage extends StatefulWidget {
  const KuWoHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KuWoHomePage();
}

class _KuWoHomePage extends State<KuWoHomePage> {
  Size? size;
  KuwoController controller = Get.find<KuwoController>();
  Widget _body = Container();
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
        body: SafeArea(

            child: Container(child:Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      // height: size.height * 0.09,
                      child: TextField(
                        autofocus:false,
                        // focusNode: FocusNode(),
                        enableInteractiveSelection: false,
                        /// 设置字体
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textInputAction: TextInputAction.done,
                        // onChanged: (value){
                        //   print(value);
                        //
                        // },
                        onSubmitted: (value) {
                       //搜索歌曲
                          Get.toNamed('/kuwosearchlist',arguments: value);
                          FocusScope.of(context).requestFocus(FocusNode());
                          // Get.back();
                        },

                        /// 设置输入框样式
                        decoration: InputDecoration(
                          hintText: '搜索',
                          /// 边框
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              /// 里面的数值尽可能大才是左右半圆形，否则就是普通的圆角形
                              Radius.circular(90),
                            ),
                          ),

                          ///设置内容内边距
                          contentPadding: EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                          ),

                          /// 前缀图标
                          prefixIcon: Icon(Icons.search),
                        ),
                      )),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    // height: size.height * 0.7,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        Container(
                          child: Column(
                            children: [
                              _body,
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ))
        )
    );
  }

  @override
  void initState() {

    Future.delayed(Duration.zero, () {
      initData();
    });
  }

  void initData() async {
    List<Widget> list = [];
    //歌曲榜单
    controller.bangMenu().then((value) => {
      for (var tl in value["data"])
        {list.add(TopListContainer(tl["list"], tl["name"]))},
      setState(() {
        _body = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: list,
        );
      })
    });

  }
}