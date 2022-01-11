import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'package:sqmusic/controller/MusicPlayController.dart';
import 'package:sqmusic/set/PlaySongSource.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:sqmusic/widget/HollowWordWidget.dart';


///2022/1/5
///榜单list列表
class KuwoBangListPage extends StatefulWidget {
  const KuwoBangListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KuwoBangListPage();
}

class _KuwoBangListPage extends State<KuwoBangListPage> {
  Size? size;
  var _image = "";
  var name = "".obs;
  //listview组件
  Widget mainbody = Container();
  //listview的控制器
  ScrollController _scrollController = ScrollController();
  //查询歌曲总数
  int _musiclistcount = 0;
  //当前页码
  int page = 0;
  //标题
  var title ="歌单列表".obs;
  //歌曲信息
  var musicList = [];
  //允许向下刷新（防止卡的时候还无线下拉）
  bool isallowdown = true;
  //控制器
  KuwoController controller = Get.find<KuwoController>();
  //音乐播放控制器 需要先进行添加后再播放跳转
  MusicPlayController musicPlayController = Get.find<MusicPlayController>();



  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        body: SafeArea(
            child: Container(
              height: size!.height,
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
                          Obx(()=> Text( name.value,style: TextStyle(fontSize: 20),)),
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
                    flex: 14,
                    child: Container(
                        height: size!.height,
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: <Widget>[
                            // 如果不是Sliver家族的Widget，需要使用SliverToBoxAdapter做层包裹
                            SliverToBoxAdapter(
                              child: Container(
                                // color: Colors.black,
                                height: size!.height * 0.25,
                                child: ClipRect(
                                  child: Container(
                                    child:Blur(
                                      blur: 30.5,
                                      blurColor: Colors.black,
                                      child: ExtendedImage.network(
                                        _image,
                                        cache: true,
                                        width: size!.width,
                                        fit: BoxFit.fill,
                                        // placeholder: (context, url) =>
                                        //     CircularProgressIndicator(),
                                      ),
                                        overlay:Center(
                                          child: HollowWordWidget(title.value,fontSize: 50,color: Colors.grey,),
                                        )
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // 当列表项高度固定时，使用 SliverFixedExtendList 比 SliverList 具有更高的性能
                            SliverFixedExtentList(
                                delegate: SliverChildBuilderDelegate(_buildListItem,
                                    childCount: musicList.length),
                                itemExtent: size!.height * 0.085),
                          ],
                        )),
                  ),
                ],
              ),
            ),
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
    if(Get.arguments != null){

      _scrollController.addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          //滑动到底部了 页码加1

          //获取新增页面数据
          if ((page + 1) * 20 >= _musiclistcount) {
            print('最后一页了');
          } else {
            print('开始新增数据$page');
            if (isallowdown) {
              isallowdown = false;
              page++;
              controller.bangInfo(sourceid:Get.arguments["id"].toString(), page: page).then((value) => {
                // print(value),
                title.value=value["name"],
                setState(() {
                  musicList.addAll(value["musiclist"]);
                }),
                isallowdown = true
              });
            } else {
              // 提示稍等在进行刷新
              OtherUtils.showToast("正在努力读取数据。。。");
              print("拉的太快了 稍等。。");
            }
          }
        }
      });

      //获取数据
      name.value = Get.arguments["name"].toString();
      // Get.arguments["id"]
      controller.bangInfo(sourceid:Get.arguments["id"].toString(), page: page).then((value) => {
        // print(value),
        title.value=value["name"],
        setState(() {
           musicList = value["musiclist"];
          _image = value["v9_pic2"].toString();
          _musiclistcount = int.parse(value["num"]);
        })
      });
    }else{
      // 返回上一页并且提示有问题
      OtherUtils.showToast("数据好像没加载成功请重试。。。");
      Get.back();
    }
  }

  // 列表项
  Widget _buildListItem(BuildContext context, int index) {
    return SizedBox(
      // height: size!.height,
      child:



      ListTile(
        title: new Text(
          (index+1).toString()+"    "+musicList[index]["name"],
          // style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        subtitle: Align(
            child: new Text(
              "       "+musicList[index]["artist"],
              // style: TextStyle(color: Colors.white54),
            ),
            alignment: FractionalOffset.topLeft),
        trailing: new Icon(Icons.keyboard_arrow_right),


        onTap: () {
          print("点击歌曲");
          print(musicList[index]["name"]);
          //判断当前歌曲是不是正在播放
          var currentPlayingMusic = musicPlayController.isCurrentPlayingMusic(songinfo: {"songName":musicList[index]["name"],"album":musicList[index]["album"],"artist":musicList[index]["artist"]},songSource: PlaySongSource.KuWo);
          Get.toNamed("/musicplay",arguments: {"refresh":!currentPlayingMusic,"data":musicList[index],"songSource":PlaySongSource.KuWo,"id":musicList[index]["id"],"isdrive":false});
        },
      ),
    );
  }

}