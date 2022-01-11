import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sqmusic/kuwo/Base64Coder.dart';
import 'package:sqmusic/kuwo/kuwoDES.dart';
import 'package:sqmusic/utils/RequestUtils.dart';

class KuwoController extends GetxController{
  // static String topCategory =  "http://iecoxe.top:5000/v1/kuwo/topCategory";
  // static String suggestSearch = "http://iecoxe.top:5000/v1/kuwo/suggestSearch";
  // static String top = "http://iecoxe.top:5000/v1/kuwo/top";
  // static String song = "http://iecoxe.top:5000/v1/kuwo/song";
  // static String lyric = "http://iecoxe.top:5000/v1/kuwo/lyric";
  //搜索歌曲
   String SearchUrl = "http://search.kuwo.cn/r.s?client=kt&encoding=utf8&rformat=json&mobi=1&vipver=1&pn=[pn]&rn=20&correct=1&all=[key]&ft=music";
   //榜单列表
   String BangMenuUrl = "http://m.kuwo.cn/newh5app/api/mobile/v1/typelist/rank";
   //榜单详情
   String BangInfoUrl ="http://kbangserver.kuwo.cn/ksong.s?from=pc&fmt=json&pn=[pn]&rn=20&type=bang&data=content&id=[sourceid]&show_copyright_off=0&pcmp4=1&isbang=1";
  //歌曲详情以及歌词
  String  SongInfoUrl =  "http://m.kuwo.cn/newh5/singles/songinfoandlrc?musicId=[musicId]";
   String downloadurl ="http://nmobi.kuwo.cn/mobi.s?f=kuwo&q=";


   ///搜索歌曲
  ///[key] 搜索关键字
  ///[page] 页码 从0开始
   Future<dynamic> search(String key,{int page =0}) async{
    String url =  SearchUrl.replaceAll("[key]", key).replaceAll("[pn]",page.toString());
    Response  response =await RequestUtils.getNoParamet(url);
    if(response.statusCode==200){
     return json.decode(response.data);
    }else{
      throw  Exception('搜索获取数据失败');
    }



    // 使用方法
    // API.search("星晴").then((data)=>{
    //   if(data.statusCode==200){
    //     json.decode(data.data)["abslist"][0]["MUSICRID"].toString().split("_")[1],
    //     print(json.decode(data.data)[0])
    //   }else{
    //     //todo 搜索请求错误
    //   }
    // });
  }

  ///榜单列表
   Future<dynamic>  bangMenu() async{
    // String url =  SearchUrl.replaceAll("[key]", key).replaceAll("[pn]",page.toString());
    Response  response =await RequestUtils.getNoParamet(BangMenuUrl);
    if(response.statusCode==200){
      // var data =json.decode(response.data);
         response =await RequestUtils.getNoParamet(BangMenuUrl);
         return response.data;
    }else {
      throw  Exception('搜索获取数据失败');
    }
  }

  ///榜单内详细歌曲
  ///[sourceid] 榜单id
   ///[page] 页码
   Future<dynamic>  bangInfo({required String sourceid,required int page}) async{
     String url =  BangInfoUrl.replaceAll("[sourceid]", sourceid.toString()).replaceAll("[pn]",page.toString());
     Response  response =await RequestUtils.getNoParamet(url);
     if(response.statusCode==200){
       var data =json.decode(response.data);
       return data;
     }else {
       throw  Exception('搜索获取数据失败');
     }
   }

   ///歌曲详细信息以及歌词
   ///[musicId]  歌曲id
   Future<dynamic>  songInfo({required String musicId}) async{
     String url =  SongInfoUrl.replaceAll("[musicId]", musicId);
     Response  response =await RequestUtils.getNoParamet(url);
     if(response.statusCode==200){
       var data =json.decode(response.data);
       response =await RequestUtils.getNoParamet(BangMenuUrl);
         return data;
     }else {
       throw  Exception('搜索获取数据失败');
     }
   }
   ///获取歌曲播放（下载）链接
   Future<dynamic>  playUrl({required String musicId,required String brvalue}) async{
    // String id ="156483846";
    String s = "user=e3cc098fd4c59ce2&android_id=e3cc098fd4c59ce2&prod=kwplayer_ar_9.3.1.3&corp=kuwo&newver=2&vipver=9.3.1.3&source=kwplayer_ar_9.3.1.3_qq.apk&p2p=1&notrace=0&type=convert_url2&br=${brvalue}&format=flac|mp3|aac&sig=0&rid=${musicId}&priority=bitrate&loginUid=435947810&network=WIFI&loginSid=1694167478&mode=download&uid=658048466";
    var encode = utf8.encode(s);
    var encrypt2 = KuwoDES.encrypt2(encode, encode.length, KuwoDES.SECRET_KEY, KuwoDES.SECRET_KEY.length);
    var encode1 = Base64Coder.encode1(encrypt2, encrypt2.length);
    String outstr = "";
    for (String o in encode1) {
      outstr+=o;
    }
    var response = await RequestUtils.getNoParamet(downloadurl+outstr);
    if(response.statusCode==200){
      return response.data;
    }else{
      throw  Exception('搜索获取数据失败');
    }
    }



   //   String url =  SongInfoUrl.replaceAll("[musicId]", musicId);
   //   Response  response =await RequestUtils.getNoParamet(url);
   //   if(response.statusCode==200){
   //     if(!response.data["success"]){
   //       response =await RequestUtils.getNoParamet(BangMenuUrl);
   //       return json.decode(response.data);
   //     }else{
   //       return response.data;
   //     }
   //   }else if(response.statusCode!=200){
   //     response =await RequestUtils.getNoParamet(BangMenuUrl);
   //     return json.decode(response.data);
   //   }
   // }


}