// @dart=2.9
//操作阿里云盘客户端
import 'dart:io';


import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliDriveApi.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/MusicCach.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';


class AliClient{
  //刷新token
  // static String refresh_token ="763ede0ddaa2442e8d936fdb09befea6";
  // drive_id
  static String drive_id ="178606";
  //请求token
  static String authorization;

  static String MusicFileId;

//刷新authorization token
  static Future<bool> refreshToken() async{
  var refreshToken = await AliDriveApi.refreshToken(SpUtil.getString(SetKey.REFRESH_TOKEN));
    if(refreshToken.statusCode!=200){
      return false;
    }
  SpUtil.putString(SetKey.REFRESH_TOKEN,refreshToken.data["refresh_token"]);
  AliClient.authorization = refreshToken.data["access_token"];
  AliClient.drive_id = refreshToken.data["default_drive_id"];
  SpUtil.putString(SetKey.ALI_NICK_NAME, refreshToken.data["nick_name"]);
  SpUtil.putString(SetKey.ALI_AVATAR, refreshToken.data["avatar"]);
   return true;
  }
  //重命名
  static Future<bool> rename( String file_id,String name) async{
    var renamedata =await  AliDriveApi.rename(authorization, drive_id, file_id: file_id, name: name);
    if(authorization==null){
      await refreshToken();
    }
    if(renamedata.statusCode==200){
      return true;
    }else{
      return false;
    }
  }

  //获取用户信息
  static Future<dynamic> userinfo() async{
    if(authorization==null){
      await refreshToken();
    }
    var userinfo = await AliDriveApi.userinfo(authorization);
    try {
     SpUtil.putString(SetKey.ALI_NICK_NAME, userinfo.data["nick_name"]);
     SpUtil.putString(SetKey.ALI_AVATAR, userinfo.data["avatar"]);
      return userinfo.data;
    } catch (e) {
      return null;
    }

  }

    // 04b8fdad646d442b9400c054c1f55067
  //创建文件夹

  static Future<String> mkdir(String parent_file_id, String name) async{
    if(authorization==null){
      await refreshToken();
    }
    var mkdirres = await AliDriveApi.mkdir(authorization,drive_id,parent_file_id,name);

    //需要刷新token
    if(mkdirres.statusCode==401){
      await refreshToken();
      return mkdir(parent_file_id,name);
    }


    try {
      return mkdirres.data["file_id"];
    } catch (e) {
      return null;
    }
  }
  //我喜欢的歌曲
  static Future<String> MyLikeSongID() async{
    if(AliClient.MusicFileId==null){
      existMusicDirectory();
    }
    //继续寻找我喜欢的这个文件夹
    var fileList = await AliDriveApi.fileList(authorization,drive_id,AliClient.MusicFileId);
    bool isExists=false;
    String mylikesongid;
    for (var item in fileList.data["items"]) {
      //找到所在文件夹
      if(item["name"]=="我喜欢的歌曲"&& item["type"]=="folder"){
        isExists=true;
        mylikesongid=item["file_id"];
        break;
      }
    }
    if(!isExists){
      //不存在则创建
      mylikesongid = await mkdir(AliClient.MusicFileId,"我喜欢的歌曲");
    }
    return mylikesongid;
  }

  // 播放列表中的所有歌曲
  static Future<Map>  PlayListSong({String playid}) async {

    List extension =["mp3","flac"];

    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.fileList(authorization,drive_id,playid);
    var resmap={};
    //继续寻找其他文件夹
    for (var item in fileList.data["items"]) {
      //找到歌曲（目前仅支持mp3和flac）
      if(item["type"]=="file"&&extension.contains(item["file_extension"])){
        resmap[item["name"].split(".")[0]]=item;
      }
    }
    return resmap;
  }

  // 播放列表中的所有歌曲x信息图片和json文件
  static Future<Map>  PlayListImageAndJson({String id}) async {
    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.fileList(authorization,drive_id,id);
    var resmap={};
    //继续寻找其他文件夹
    for (var item in fileList.data["items"]) {
      if(item["type"]=="file"){
        resmap[item["name"].split(".")[0]]=item;
      }
    }
    return resmap;
  }




  ///所有歌单文件夹
  static Future<Map>  MusicPlayList({String playid}) async {
    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.fileList(authorization,drive_id,playid);
    var resmap={};
    //继续寻找其他文件夹
    for (var item in fileList.data["items"]) {
      //找到所在文件夹
      if(item["type"]=="folder"){
          resmap[item["name"]]=item["file_id"];
      }
    }
    return resmap;
  }

  //找到播放列表下的歌曲信息没有则创建
  static Future<String> MusicPlayListJsonID({String id}) async {
    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.fileList(authorization,drive_id,id);
    //继续寻找其他文件夹
    String res;
    for (var item in fileList.data["items"]) {
      //找到所在文件夹
      if(item["type"]=="folder"&&item["name"]=="data"){
        res=item["file_id"];
        return res;
      }
    }
      return await mkdir(id,"data");


  }
  //找到播放列表下的歌曲信息没有则创建
  static Future<String> MusicPlayListImgID({String id}) async {
    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.fileList(authorization,drive_id,id);
    //继续寻找其他文件夹
    String res;
    for (var item in fileList.data["items"]) {
      //找到所在文件夹
      if(item["type"]=="folder"&&item["name"]=="img"){
        res=item["file_id"];
        return res;
      }
    }
      return await mkdir(id,"img");


  }

  //找到播放列表下的歌曲信息没有则创建
  ///[parent_file_id] 文件夹id
  ///[name] 文件名称
  static Future<dynamic> search({String parent_file_id,String name,String file_extension}) async {
    if(authorization==null){
      await refreshToken();
    }
    var fileList = await AliDriveApi.Search(authorization,drive_id,parent_file_id,name: name,file_extension:file_extension);
    if(fileList.data["items"].length==0){
      return null;
    }
    return fileList.data["items"][0];
  }

    ///是否存在muisc文件夹不存在则创建
  static Future<String>  existMusicDirectory({String MusicSongSour}) async {
    if(MusicFileId!=null&&MusicSongSour==null){
      return MusicFileId;
    }

    if(authorization==null){
      await refreshToken();
    }
  //找到相对的文件夹
    var fileList = await AliDriveApi.fileList(authorization,drive_id,"root");
//需要刷新token
    if(fileList.statusCode==401){
      await refreshToken();
      return existMusicDirectory(MusicSongSour:MusicSongSour);
    }
    //默认不存在music文件夹
    bool isExists =false;
    //music文件夹的id
    String musicFileId;
    //继续寻找其他文件夹
    for (var item in fileList.data["items"]) {
        //找到所在文件夹
      if(item["name"]=="SqMusic"&& item["type"]=="folder"){
        musicFileId =  item["file_id"];
        isExists=true;
        break;
      }
    }
    if(!isExists){
      //不存在则创建
      var mkdirmusicdata = await mkdir("root","SqMusic");
      if(mkdirmusicdata!=null){
        musicFileId = mkdirmusicdata;
      }
    }
    if(MusicSongSour==null){
      return musicFileId;
    }else{
      var fileList2 = await AliDriveApi.fileList(authorization,drive_id,musicFileId);
      bool temp =false;
      for (var item in fileList2.data["items"]) {
        if(item["name"]==MusicSongSour&& item["type"]=="folder"){
          return item["file_id"];
          temp=true;
        }
      }
      if(!temp){
        String MusicSongSourID = await mkdir(musicFileId,MusicSongSour);
        if(MusicSongSourID!=null){
         return MusicSongSourID;
        }
      }

    }

  }



  // //是否存在db配置文件
  // static Future<dynamic> existConifDB() async {
  //   var musicFileId = await existMusicDirectory();
  //   if(musicFileId!=null){
  //     //打开muisc文件夹查看db文件
  //     if(authorization==null){
  //       await refreshToken();
  //     }
  //     var fileList = await AliDriveApi.fileList(authorization,drive_id,musicFileId);
  //
  //     //需要刷新token
  //     if(fileList.statusCode==401){
  //       await refreshToken();
  //       return existConifDB();
  //     }
  //
  //     //查找config.db文件
  //     for (var item in fileList.data["items"]) {
  //       //找到所在文件夹
  //         if(item["name"]=="config.db"&& item["type"]=="file"){
  //          return item;
  //       }
  //     }
  //     return null;
  //   }else{
  //     //无法创建文件夹
  //     return null;
  //   }
  //
  // }
  ///
  static Future  getDownloadUrl(String file_id) async {
    if(authorization==null){
      await refreshToken();
    }
    var response = await AliDriveApi.get_download_url(authorization,drive_id, file_id);
    //需要刷新token
    if(response.statusCode==401){
      await refreshToken();
      return getDownloadUrl(file_id);
    }
    return response;
  }




  static Future downloadFile(String download_url,String download_size,String download_path,String download_name) async {
    // String download_url,String download_size,
    if(authorization==null){
      await refreshToken();
    }


   // var download_file_response = await AliDriveApi.get_download_url(authorization,drive_id,file_id);
    //需要刷新token
    // if(download_file_response.statusCode==401){
    //   await refreshToken();
    //   return downloadFile(file_id,download_path,download_name);
    // }
    // if(download_name==null){
    //   download_name = download_file_response
    // }
    var response = await AliDriveApi.download_file(authorization,download_url, download_size, download_path, download_name);

    //需要刷新token
    if(response.statusCode==401){
      await refreshToken();
      return downloadFile(download_url, download_size, download_path, download_name);
    }
    return response;
  }

  static Future<Response> delFile(String file_id) async{

    if(authorization==null){
      await refreshToken();
    }
    var response = await AliDriveApi.del_file(authorization, drive_id, file_id);
    //需要刷新token
    if(response.statusCode==401){
      await refreshToken();
      return delFile(file_id);
    }
    if(response.statusCode==204){
      return response;
    }
    return null;
  }


  static Future<dynamic> uploadFile({String file_path,String parent_file_id,String name}) async {
    if(authorization==null){
      await refreshToken();
    }
    var uploadFile = await AliDriveApi.uploadFile(authorization, drive_id, file_path, name,parent_file_id);
    return uploadFile.data;
  }

  // 删除歌曲(以及歌曲下的图片还有数据信息)
  static Future<bool> delSong(dynamic songinfo) async {
   var res1 = await delFile(songinfo["song"]["file_id"]);
   var res2 = await delFile(songinfo["image"]["file_id"]);
   var res3 = await delFile(songinfo["json"]["file_id"]);
    if(res1.statusCode==204){
      return true;
    }else{
      return false;
    }
  }
  ///添加歌曲
  ///[forceadd] 是否强制添加歌曲（有重复歌曲）
  ///[MusicPath] 手机文件路径
  static Future<bool> addSongToAliDrive(
      { bool forceadd = false, //是否强制上传（根据名称 名称一样会覆盖云盘当前音乐）
        dynamic MusicInfo,  //歌曲信息
        String file_id, //上传文件夹信息/
      }) async {

    try {
      String convert;
      if (forceadd) {
            convert = MusicCach.generateSha1(Uuid().v4().toString());
          } else {
            convert = MusicCach.simpleMusicGenerateSha1(
                MusicName: MusicInfo["data"]["songinfo"]["songName"],
                MusicArtists: MusicInfo["data"]["songinfo"]["artist"],
                MusicAlbum: MusicInfo["data"]["songinfo"]["album"],
                MusicSongSour: MusicInfo["data"]["SongSour"]);
          }
      var MusicImagePath;
      var MusicjsonPath;
      var searcachname;
      var searcachfile =  MusicCach.searcachfile(convert + MusicInfo["suffix"]);
      if (searcachfile != null) {
            searcachname=searcachfile.path;
          } else {
            searcachname = await MusicCach.cachfile(MusicInfo["playurl"], convert + MusicInfo["suffix"]);
            }


      //缓存图片（jpg）
      var searcachimagefile =  MusicCach.searcachfile(convert +".jpg");
      if(searcachimagefile==null){
            MusicImagePath= await MusicCach.cachfile( MusicInfo["data"]["songinfo"]["pic"], convert +".jpg");
            searcachimagefile =  MusicCach.searcachfile(convert +".jpg");
          }

      //缓存歌曲信息
      var searcachjsonfile =   MusicCach.searcachfile(convert +".json");
      if(searcachjsonfile==null){

            String jsondata = json.encode(MusicInfo);
            MusicjsonPath =await MusicCach.cachjsonfile(jsondata, convert +".json");
             // searcachjsonfile =  MusicCach.searcachfile(convert +".json");
          }
      //开始上传歌曲
      String  upname = MusicInfo["data"]["songinfo"]["songName"]+" - "+MusicInfo["data"]["songinfo"]["artist"];
      var uploadover;
      try {
        uploadover =await uploadFile(
                      file_path: searcachname, parent_file_id: file_id, name: upname+MusicInfo["suffix"]);
      } catch (e) {
         uploadover =await uploadFile(
            file_path: searcachname, parent_file_id: file_id, name: upname+MusicInfo["suffix"]);
      }

      if(uploadover!=null){
            //上传成功 继续上传其他信息
           var imgid = await MusicPlayListImgID(id:file_id);
           try {
             uploadFile(file_path: searcachimagefile.path, parent_file_id: imgid, name: "$upname.jpg");
           } catch (e) {
             uploadFile(file_path: searcachimagefile.path, parent_file_id: imgid, name: "$upname.jpg");
           }

           var jsonid = await MusicPlayListJsonID(id:file_id);
           try {
             uploadFile(file_path: searcachjsonfile.path, parent_file_id: jsonid, name: "$upname.json");
           } catch (e) {
             var searcachjsonfile =   MusicCach.searcachfile(convert +".json");
             if(searcachjsonfile==null){

               String jsondata = json.encode(MusicInfo);
               MusicjsonPath =await MusicCach.cachjsonfile(jsondata, convert +".json");
               // searcachjsonfile =  MusicCach.searcachfile(convert +".json");
             }
             uploadFile(file_path: searcachjsonfile.path, parent_file_id: jsonid, name: "$upname.json");
           }
           return true;
          }else{
            //上传失败
            return false;
          }
    } catch (e) {
      print(e);
      return false;
    }
  }

   static Future RefresPlayListByNameInfo(String name) async{
    //歌曲文件夹地址
     int reftime =1000;
     try {
      if(name==null){
            name="我喜欢的歌曲";
          }
      String playList =SpUtil.getObject(SetKey.ALI_MUSICDIR)[name];
      //查找播放列表中的图片信息
      String musicPlayListImgID;
      try {
            musicPlayListImgID = await AliClient.MusicPlayListImgID(id:playList);
          } catch (e) {
            musicPlayListImgID = await AliClient.MusicPlayListImgID(id:playList);
          }
      var ALI_MUSICIMAGEDIR = SpUtil.getObject(SetKey.ALI_MUSICIMAGEDIR);
      ALI_MUSICIMAGEDIR[playList]=musicPlayListImgID;
      SpUtil.putObject(SetKey.ALI_MUSICIMAGEDIR, ALI_MUSICIMAGEDIR);
      // DBUtil.instance.alimusicimagedir.put(playList, musicPlayListImgID);
      //查找播放列表中的歌曲信息
      String musicPlayListJsonID;
      try {
            musicPlayListJsonID = await AliClient.MusicPlayListJsonID(id:playList);
          } catch (e) {
            musicPlayListJsonID = await AliClient.MusicPlayListJsonID(id:playList);
          }
      var ALI_MUSICJSONDIR = SpUtil.getObject(SetKey.ALI_MUSICJSONDIR);
      ALI_MUSICJSONDIR[playList]=musicPlayListJsonID;
      SpUtil.putObject(SetKey.ALI_MUSICJSONDIR, ALI_MUSICJSONDIR);

      // DBUtil.instance.alimusicjsondir.put(playList, musicPlayListJsonID);
      //获取所有歌曲
      Map map;
      try {
            map= await AliClient.PlayListSong(playid: playList);
          } catch (e) {
            map= await AliClient.PlayListSong(playid: playList);
          }
      var ALI_MUSICSONGDATA = SpUtil.getObject(SetKey.ALI_MUSICSONGDATA);
      ALI_MUSICSONGDATA[playList]=map;
      SpUtil.putObject(SetKey.ALI_MUSICSONGDATA, ALI_MUSICSONGDATA);
      // DBUtil.instance.alimusicsongdata.put(playList, map);
      //获取歌曲的图片地址
      Map playListImage;
      try {
            playListImage = await AliClient.PlayListImageAndJson(id:musicPlayListImgID);
          } catch (e) {
            playListImage = await AliClient.PlayListImageAndJson(id:musicPlayListImgID);
          }
      Map playListJson;
      try {
            playListJson = await AliClient.PlayListImageAndJson(id:musicPlayListJsonID);
          } catch (e) {
            playListJson  = await AliClient.PlayListImageAndJson(id:musicPlayListJsonID);
          }
      Map<String ,dynamic> songinfo = Map();
      Map<String ,dynamic> songinfo2 = Map();
      //将数据进行封装
      for (String name in map.keys) {
            //将歌曲名称的后缀分离
            songinfo[name]={
              "name":name,
              "song":map,
              "image":playListImage[name],
              "json":playListJson[name]
            };
            songinfo2[map[name]["file_id"]]={
              "name":name,
              "song":map[name],
              "image":playListImage[name],
              "json":playListJson[name]
            };
          }
      //



      Map ALI_MUSICDATA = SpUtil.getObject(SetKey.ALI_MUSICDATA);
      //清除数据在写入
      ALI_MUSICDATA.remove(playList);
      ALI_MUSICDATA[playList]=songinfo;
      SpUtil.putObject(SetKey.ALI_MUSICDATA, ALI_MUSICDATA);

      var ALI_MUSICDATABYID = SpUtil.getObject(SetKey.ALI_MUSICDATABYID);
      ALI_MUSICDATABYID.remove(playList);
      ALI_MUSICDATABYID[playList]=songinfo2;
      SpUtil.putObject(SetKey.ALI_MUSICDATABYID, ALI_MUSICDATABYID);
    } catch (e) {
      Future.delayed(Duration(milliseconds: reftime), () {
        if(reftime>3000){
          return false;
        }else{
          reftime+1000;
          RefreshPlaylistInfo();
        }

      });
    }

  }
  //刷新歌单信息
  static Future<String>  RefreshPlaylistInfo() async{
   int reftime =1000;
  try{
    //情况缓存避免数据污染
    DBUtil.cliearali();
    //歌曲文件夹地址
    String sqmusicpath;
    try {
      sqmusicpath= await AliClient.existMusicDirectory();
    } catch (e) {
      sqmusicpath = await AliClient.existMusicDirectory();
    }
    //扫描所有子目录（每个目录都是一个歌单）
    Map musicPlayList;
    try {
      musicPlayList= await AliClient.MusicPlayList(playid: sqmusicpath);
    } catch (e) {
      musicPlayList= await AliClient.MusicPlayList(playid: sqmusicpath);
    }


    if(musicPlayList.length==0){
      //没有音乐文件夹则创建我喜欢的音乐文件夹
      String mkdirid;
     try {
       mkdirid= await AliClient.mkdir(sqmusicpath, "我喜欢的歌曲");
     } catch (e) {
       mkdirid= await AliClient.mkdir(sqmusicpath, "我喜欢的歌曲");
     }
      try {
        musicPlayList = await AliClient.MusicPlayList(playid: sqmusicpath);
      } catch (e) {
        musicPlayList = await AliClient.MusicPlayList(playid: sqmusicpath);
      }
    // return mkdirid;
    }
    for (var item in musicPlayList.keys) {
      var ALI_MUSICDIR = SpUtil.getObject(SetKey.ALI_MUSICDIR);
      ALI_MUSICDIR[item]=musicPlayList[item];
      SpUtil.putObject(SetKey.ALI_MUSICDIR, ALI_MUSICDIR);

      // DBUtil.instance.alimusic.put(DBUtil.ALIMUSICDIR, DBUtil.instance.alimusic.get(DBUtil.ALIMUSICDIR).put(item, musicPlayList[item]));
      //查找播放列表中的图片信息
      String musicPlayListImgID;
      try {
        musicPlayListImgID= await AliClient.MusicPlayListImgID(id:musicPlayList[item]);
      } catch (e) {
        musicPlayListImgID= await AliClient.MusicPlayListImgID(id:musicPlayList[item]);
      }
      var ALI_MUSICIMAGEDIR = SpUtil.getObject(SetKey.ALI_MUSICIMAGEDIR);
      ALI_MUSICIMAGEDIR[musicPlayList[item]] =musicPlayListImgID;
      SpUtil.putObject(SetKey.ALI_MUSICIMAGEDIR, ALI_MUSICIMAGEDIR);
      //查找播放列表中的歌曲信息
      String musicPlayListJsonID;
      try {
        musicPlayListJsonID= await AliClient.MusicPlayListJsonID(id:musicPlayList[item]);
      } catch (e) {
        musicPlayListJsonID= await AliClient.MusicPlayListJsonID(id:musicPlayList[item]);
      }
      var ALI_MUSICJSONDIR = SpUtil.getObject(SetKey.ALI_MUSICJSONDIR);
      ALI_MUSICJSONDIR[musicPlayList[item]]=musicPlayListJsonID;
      SpUtil.putObject(SetKey.ALI_MUSICJSONDIR, ALI_MUSICJSONDIR);

      //获取所有歌曲
      Map map ;
      try {
        map=await AliClient.PlayListSong(playid: musicPlayList[item]);
      } catch (e) {
        map=await AliClient.PlayListSong(playid: musicPlayList[item]);
      }
      var ALI_MUSICSONGDATA = SpUtil.getObject(SetKey.ALI_MUSICSONGDATA);
      ALI_MUSICSONGDATA[musicPlayList[item]]=map;
      SpUtil.putObject(SetKey.ALI_MUSICSONGDATA, ALI_MUSICSONGDATA);
      //获取歌曲的图片地址
      Map playListImage;
      try {
        playListImage= await AliClient.PlayListImageAndJson(id:musicPlayListImgID);
      } catch (e) {
        playListImage= await AliClient.PlayListImageAndJson(id:musicPlayListImgID);
      }
      Map playListJson;
      try {
         playListJson  = await AliClient.PlayListImageAndJson(id:musicPlayListJsonID);
      } catch (e) {
        playListJson  = await AliClient.PlayListImageAndJson(id:musicPlayListJsonID);
      }
      Map<String ,dynamic> songinfo = Map();
      Map<String ,dynamic> songinfo2 = Map();
      //将数据进行封装
      for (String name in map.keys) {
        //将歌曲名称的后缀分离
        songinfo[name]={
          "name":name,
          "song":map[name],
          "image":playListImage[name],
          "json":playListJson[name]
        };
        songinfo2[map[name]["file_id"]]={
          "name":name,
          "song":map,
          "image":playListImage[name],
          "json":playListJson[name]
        };
      }
      var ALI_MUSICDATA = SpUtil.getObject(SetKey.ALI_MUSICDATA);
      ALI_MUSICDATA[musicPlayList[item]]= songinfo;
      SpUtil.putObject(SetKey.ALI_MUSICDATA, ALI_MUSICDATA);

      var ALI_MUSICDATABYID = SpUtil.getObject(SetKey.ALI_MUSICDATABYID);
      ALI_MUSICDATABYID[musicPlayList[item]]= songinfo2;
      SpUtil.putObject(SetKey.ALI_MUSICDATABYID, ALI_MUSICDATABYID);
    }
  } catch (e) {
    Future.delayed(Duration(milliseconds: reftime), () {
      if(reftime>3000){
        return false;
      }else{
        reftime+1000;
        RefreshPlaylistInfo();
      }

    });

    }


  }
  //将歌曲info转为json数据
  static Future<String>  aliSongInfoToJson(String download_url,download_size) async{
    //下载
     return await AliDriveApi.download_file_to_string(AliClient.authorization,download_url,download_size);

  }


}