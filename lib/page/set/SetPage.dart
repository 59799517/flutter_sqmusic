import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/set/PlaySongQuality.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/ToastUtil.dart';
import 'package:sqmusic/widget/FLListTile.dart';
import 'package:get/get.dart';

///2022/1/5
///
class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SetPage();
}

class _SetPage extends State<SetPage> {
  List<String> dropdownlist = ['128MP3', '192MP3', '320MP3', '2000FLAC'];
  // List<String> dropdownlist = ['128MP3', '192MP3', '320MP3'];

  //选择音质
  var dropdownindex = "".obs;

  //缓存
  var cache = false.obs;

  //打开与云盘
  var opdrive = false.obs;

  //刷新token信息
  var res_token = "".obs;
  Size? size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    // dropdownindex.value = dropdownlist[0];
    return Scaffold(
        backgroundColor: Colors.grey[300],
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //头像部分
            // Container(
            //   color: Colors.white,
            //   child: Expanded(
            //     flex: 5,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Container(
            //           child: GFAvatar(
            //             backgroundImage:NetworkImage("https://image.ionicfirebaseapp.com/getwidget/Home_service_app_d88471cce9.png?tr=w-1200"),
            //           ),
            //         ),
            //         Container(
            //           child: Text("云盘登录名称"),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            // 间隔条
            Container(
              // color: Colors.red,
              child: Container(
                child: FLListTile(
                  isThreeLine: false,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    "播放器设置",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            //设置部分

            Container(
              child: Container(
                child: FLListTile(
                  isThreeLine: false,
                  // backgroundColor:
                  // Colors
                  //     .yellow,
                  title: Text("播放音质"),
                  trailing: Container(
                    child: DropdownButtonHideUnderline(
                      child: Obx(() => GFDropdown(
                            // padding: const EdgeInsets.all(15),
                            // borderRadius: BorderRadius.circular(5),
                            // border: const BorderSide(
                            //     color: Colors.black12, width: 1),
                            dropdownButtonColor: Colors.white,
                            value: dropdownindex.value,
                            onChanged: (newValue) {
                              dropdownindex.value = newValue.toString();
                              songQuality(dropdownindex.value);
                              if(newValue.toString()==dropdownlist[3]){
                                OtherUtils.showToast("flac播放存在一些问题谨慎使用");
                                //强制检查是否开启缓存播放
                                // if(cache.value){

                                  // if(dropdownindex.value==3){
                                  //
                                  // }

                                // }else{
                                //   OtherUtils.showToast("请开始缓存播放后再选择flac格式");
                                // }
                              }else{
                                songQuality(dropdownindex.value);
                              }

                            },
                            items: dropdownlist
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                          )),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Container(
                child: FLListTile(
                  isThreeLine: false,
                  // backgroundColor:
                  // Colors
                  //     .yellow,
                  title: Text("缓存播放"),
                  trailing: Obx(() => GFToggle(
                        onChanged: (val) {
                          cache.value = val!;
                          SpUtil.putBool(SetKey.CACHE_PLAY, val);
                        },
                        value: cache.value,
                        type: GFToggleType.custom,
                      )),
                ),
              ),
            ),
           Container(
              // color: Colors.red,
              child: Obx(() => Container(
                    child: FLListTile(
                      isThreeLine: false,
                      // backgroundColor:
                      // Colors
                      //     .yellow,
                      title: Text("云盘同步"),
                      trailing: GFToggle(
                        onChanged: (val) {
                          opdrive.value = val!;
                          SpUtil.putBool(SetKey.OPEN_ALIDRIVE, val);
                        },
                        value: opdrive.value,
                        type: GFToggleType.custom,
                      ),
                    ),
                  )),
            ),
            Container(
              child: FLListTile(
                isThreeLine: false,
                // backgroundColor:
                // Colors
                //     .yellow,
                title: Text("token设置"),
                trailing: GFButton(
                  type: GFButtonType.transparent,
                    shape: GFButtonShape.pills,
                    textStyle: TextStyle(color: Colors.black),
                    onPressed: (){
                    if(opdrive.value){
                        Get.offAndToNamed("/checktoken");
                    }else{
                     OtherUtils.showToast("请打开云盘同步功能后添加。");
                    }
                    },
                text:res_token.value==""?"添加token":"修改token"
                ),
              ),
            ),
          ],
        )));
  }

  @override
  void initState() {
   var selfquality = SpUtil.getString(SetKey.PLAY_SONG_QUALITY);
   if(selfquality==PlaySongQuality.KuWo_mp3_128){
     dropdownindex.value = dropdownlist[0];
   }else if(selfquality==PlaySongQuality.KuWo_mp3_192){
     dropdownindex.value = dropdownlist[1];
   }else if(selfquality==PlaySongQuality.KuWo_mp3_320){
     dropdownindex.value = dropdownlist[2];
   }else if(selfquality==PlaySongQuality.KuWo_flac_2000){
     dropdownindex.value = dropdownlist[3];
   }else{
     SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_mp3_320);
     OtherUtils.showToast("音质错误强制修改为320MP3");
   }


    cache.value = SpUtil.getBool(SetKey.CACHE_PLAY)!;
    opdrive.value = SpUtil.getBool(SetKey.OPEN_ALIDRIVE)!;
    if(SpUtil.containsKey(SetKey.REFRESH_TOKEN)!){
      res_token.value = SpUtil.getString(SetKey.REFRESH_TOKEN)!;
    }
  }


  // chenkAliToken(String token) async{
  //   var put = await DBUtil.instance!.userinfo!.put(SetKey.REFRESH_TOKEN,token);
  //   var bool=false;
  //   try {
  //     bool= await AliClient.refreshToken();
  //   } catch (e) {
  //     bool=false;
  //   }
  //   if(bool){
  //     return bool;
  //   }else{
  //
  //   return false;
  //   }
  //
  //
  // }

  songQuality(String quality){
    if(quality=="128MP3"){
      SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_mp3_128);
    }else if(quality=="192MP3"){
      SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_mp3_192);
    }else if(quality=="320MP3"){
      SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_mp3_320);
    }else if(quality=="2000FLAC"){
      SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_flac_2000);
    }else{
      SpUtil.putString(SetKey.PLAY_SONG_QUALITY,PlaySongQuality.KuWo_mp3_320);
      OtherUtils.showToast("选择错误强制修改为320MP3");
    }
  }



}
