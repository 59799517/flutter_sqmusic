import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/set/PlaySongQuality.dart';
import 'package:sqmusic/set/SetKey.dart';

/// 2022/1/5
///
class DBUtil  {






  // //key：阿里云的歌单名称     value：歌单的目录id
  //   Box? alimusicdir;
  // // key 歌单的目录id   value 整理好的歌曲信息
  //    Box? alimusicdata;
  // //   key 歌单的目录id   value 整理好的歌曲信息   根据id查询的
  //    Box? alimusicdatabyid;
  // // ey 歌单的目录id   value 整理好的歌曲信息   列表
  //   Box? alimusicsongdata;
  // // key 歌单的目录id  value：歌单下对应的json数据目录id
  //   Box? alimusicjsondir;
  // // key 歌单的目录id  value：歌单下对应的图片数据目录id
  //   Box? alimusicimagedir;



static cliearali(){
  SpUtil.remove(SetKey.ALI_MUSICDIR);
  SpUtil.putObject(SetKey.ALI_MUSICDIR, Map());
  SpUtil.remove(SetKey.ALI_MUSICDATA);
  SpUtil.putObject(SetKey.ALI_MUSICDATA, Map());
  SpUtil.remove(SetKey.ALI_MUSICDATABYID);
  SpUtil.putObject(SetKey.ALI_MUSICDATABYID, Map());
  SpUtil.remove(SetKey.ALI_MUSICSONGDATA);
  SpUtil.putObject(SetKey.ALI_MUSICSONGDATA, Map());
  SpUtil.remove(SetKey.ALI_MUSICJSONDIR);
  SpUtil.putObject(SetKey.ALI_MUSICJSONDIR, Map());
  SpUtil.remove(SetKey.ALI_MUSICIMAGEDIR);
  SpUtil.putObject(SetKey.ALI_MUSICIMAGEDIR, Map());

  // //key：阿里云的歌单名称     value：歌单的目录id
  // instance!.alimusicdir!.clear();
  // // key 歌单的目录id   value 整理好的歌曲信息
  // instance!.alimusicdata!.clear();
  // //   key 歌单的目录id   value 整理好的歌曲信息   根据id查询的
  // instance!.alimusicdatabyid!.clear();
  // // ey 歌单的目录id   value 整理好的歌曲信息   列表
  // instance!.alimusicsongdata!.clear();
  // // key 歌单的目录id  value：歌单下对应的json数据目录id
  // instance!.alimusicjsondir!.clear();
  // // key 歌单的目录id  value：歌单下对应的图片数据目录id
  // instance!.alimusicimagedir!.clear();
  }

  /// 初始化，需要在 main.dart 调用
  /// <https://docs.hivedb.dev/>
  static Future<void> install() async {
      await SpUtil.getInstance();
      SpUtil.containsKey(SetKey.APP_FIRST)!?SpUtil.putBool("first", false):SpUtil.putBool("first", true);
      if(!SpUtil.containsKey(SetKey.OPEN_ALIDRIVE)!){
        SpUtil.putBool(SetKey.OPEN_ALIDRIVE, false);
      }
      if(!SpUtil.containsKey(SetKey.PLAY_SONG_QUALITY)!){
        SpUtil.putString(SetKey.PLAY_SONG_QUALITY, PlaySongQuality.KuWo_mp3_320);
      }
      if(!SpUtil.containsKey(SetKey.CACHE_PLAY)!){
        SpUtil.putBool(SetKey.CACHE_PLAY, false);
      }
      if(!SpUtil.containsKey(SetKey.PLAY_SONG_LOOP)!){
        SpUtil.putInt(SetKey.PLAY_SONG_LOOP, 2);
      }

      if(!SpUtil.containsKey(SetKey.ALI_MUSICDIR)!){
        SpUtil.putObject(SetKey.ALI_MUSICDIR, Map());
      }
      // if(!SpUtil.containsKey(SetKey.ALI_MUSICDATA)!){
      //   SpUtil.putObject(SetKey.ALI_MUSICDATA, Map());
      // }
      // if(!SpUtil.containsKey(SetKey.ALI_MUSICDATABYID)!){
      //   SpUtil.putObject(SetKey.ALI_MUSICDATABYID, Map());
      // }
      if(!SpUtil.containsKey(SetKey.ALI_MUSICSONGDATA)!){
        SpUtil.putObject(SetKey.ALI_MUSICSONGDATA, Map());
      }
      if(!SpUtil.containsKey(SetKey.ALI_MUSICJSONDIR)!){
        SpUtil.putObject(SetKey.ALI_MUSICJSONDIR, Map());
      }
      if(!SpUtil.containsKey(SetKey.ALI_MUSICIMAGEDIR)!){
        SpUtil.putObject(SetKey.ALI_MUSICIMAGEDIR, Map());
      }

  }
  //是否首次登陆
  static bool firstApp(){
    return SpUtil.getBool(SetKey.APP_FIRST)!;
  }

}