
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:sqmusic/utils/MusicCach.dart';
import 'package:sqmusic/utils/SQCookieManager.dart';

class RequestUtils{
  static Dio dio = new Dio(BaseOptions(responseType: ResponseType.json))..interceptors.add(SQCookieManager(CookieJar()));
  // static Options options = null;
  // var baseOptions = ;
  static Future<Response> postUri(Uri uri,Map data) async {
    return await dio.postUri(uri,data: data);
  }

  static Future<Response> get(String uri ,Map<String, dynamic> queryParameters) async {
    return await dio.get(uri,queryParameters: queryParameters);
  }
  static Future<Response> getNoParamet(String uri ) async {
    // if(uri.contains("bang/bang/bangMenu")){
    //   var kwCookies = SQCookieManager.kwCookies;
    //   print(kwCookies);
    //   var headers = dio.options.headers;
    //   var cookies = headers["cookies"];
    //   print(cookies);
    // }

    return await dio.get(uri);
  }
  ///[filename] 必须带后缀
  static Future<Response> downloadFile(String url,String filename) async {
    return await dio.download(url, MusicCach.directory!.path+"/"+filename,onReceiveProgress: (int count, int total){
      print("下载进度：$total 共计$count 百分比 "+(count/total).toString());
    });
  }
  static Future<Response> getMasterColor(String uri) async {
    return await dio.get("http://iecoxe.top:5000/v1/scavengers/getMasterColor",queryParameters: {"imgUrl":uri});
  }


}