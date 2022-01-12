import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'package:sqmusic/controller/MusicPlayController.dart';
import 'package:sqmusic/set/PlaySongSource.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:sqmusic/widget/FLListTile.dart';

///2022/1/9
///
class KuwoSearchListPage extends StatefulWidget {
  const KuwoSearchListPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KuwoSearchListPage();
}

class _KuwoSearchListPage extends State<KuwoSearchListPage> {
  Size? size;
  KuwoController controller = Get.find<KuwoController>();
  MusicPlayController musicPlayController = Get.find<MusicPlayController>();


  //listview的控制器
  ScrollController _scrollController = ScrollController();
  //查询歌曲总数
  int _musiclistcount = 0;
  //当前页码
  int page = 0;
  //歌曲信息
  List<dynamic>? musicList ;
  //允许向下刷新（防止卡的时候还无线下拉）
  bool isallowdown = true;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Container(
              height: size!.height,
              width: size!.width,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      child:         Row(
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
                            child: Text("搜索",style: TextStyle(fontSize: 20),),
                          ),
                          Container(
                            child:       IconButton(
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
                      child: musicList==null?Container():ListView.builder(
                        controller: _scrollController,
                          itemBuilder: (BuildContext context, int index) =>_buildListItem(context,index),
                              itemCount: musicList!.length,
                      ),
                    ),
                  ),
                ],
              )
            )
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
    if(Get.arguments!=null){

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
              controller.search(Get.arguments,page: page).then((value) => {
                // print(value),
                setState(() {
                  musicList!.addAll(value["abslist"]);
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


      controller.search(Get.arguments,page: page).then((value) => {
        // //总条数
        // value["TOTAL"],
        // //数据详情
        // value["abslist"],
        // //歌曲名称
        // value["abslist"]["NAME"],
        // //歌手
        // value["abslist"]["ARTIST"],
        // //专辑
        // value["abslist"]["ALBUM"],
        // //封面图片
        // "https://img4.kuwo.cn/star/albumcover/"+value["abslist"]["web_albumpic_short"],
        // //id
        // value["abslist"]["MUSICRID"].toString().split("_")[1],
      setState(() {
        musicList=value["abslist"];
        _musiclistcount =int.parse(value["TOTAL"]);
      })


      });

    }else{
      Get.back();
      OtherUtils.showToast("搜索页面错误");
    }
  }
  // 列表项
  Widget _buildListItem(BuildContext context, int index) {

    var showimage =("https://img3.kuwo.cn/star/albumcover/"+musicList![index]["web_albumpic_short"]).replaceAll("/120", "/500");

    if(musicList![index]["web_albumpic_short"]==""){
       showimage =("https://img3.kuwo.cn/star/starheads/"+musicList![index]["web_artistpic_short"]).replaceAll("/120", "/500");
    }



    return  SizedBox(
      // height: 20,
      child: FLListTile(
        isThreeLine:
        false,
        // backgroundColor:
        // Colors
        //     .transparent,
        leading:ExtendedImage.network(showimage,cache: true,fit: BoxFit.fill,width: 50,),

        //     .network(
        //   ,
        //   cache: true,
        //   // fit: BoxFit
        //   //     .fill,
        // ),

        // ImageUtils.Base64toImage(_records[item]['musicImage']),
        title: new Text(
          musicList![index]["NAME"],
          style:
          TextStyle(
            fontSize:
            20,
          ),
        ),
        subtitle: Align(
            child:
            new Text(
              musicList![index]["ARTIST"],
              // style: TextStyle(
              //     color: Colors.white54),
            ),
            alignment:
            FractionalOffset
                .topLeft),
        trailing:
        new Icon(
          Icons
              .keyboard_arrow_right,
          // color: Colors.white,
        ),
        onTap: () {
          print("点击歌曲");
          print(musicList![index]["NAME"]);

          var currentPlayingMusic = musicPlayController.isCurrentPlayingMusic(songinfo: {"songName":musicList![index]["NAME"],"album":musicList![index]["ALBUM"],"artist":musicList![index]["ARTIST"]},songSource: PlaySongSource.KuWo);

          Get.toNamed("/musicplay",arguments: {"refresh":true,"data":musicList![index],"songSource":PlaySongSource.KuWo,"id":musicList![index]["MUSICRID"].toString().split("_")[1],"isdrive":false},);
        },
      ),
    );
  }
}