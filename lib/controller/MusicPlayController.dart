import 'dart:core';
import 'dart:io';
import 'dart:math';


import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/kuwo/kuwoDES.dart';
import 'package:sqmusic/set/PlaySongSource.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/MusicCach.dart';


class MusicPlayController extends GetxController {



  //播放工具
  AssetsAudioPlayer? _assetsAudioPlayer=AssetsAudioPlayer.withId("sqmusic");

  // //播放列表
  static Playlist? audios =Playlist();

  //当前播放状态
  var isPlaying = false.obs;

  final DateFormat _dateFormat = DateFormat('mm:ss');

  init(){
    assetsAudioPlayer!.open(audios!,
        autoStart: false,
        playInBackground: PlayInBackground.enabled,
        showNotification: true,
        notificationSettings: NotificationSettings(
          stopEnabled: false,
        ),
        loopMode: LoopMode.playlist);
    return assetsAudioPlayer;
  }


  // @override
  void onInitsd(){
    //播放列表
    assetsAudioPlayer!.currentPosition.listen((event) {
      if (event.inMicroseconds >=
          assetsAudioPlayer!.current.value!.audio.duration.inMicroseconds) {
        if (assetsAudioPlayer!.currentLoopMode!.index == 0) {
          assetsAudioPlayer!.playlistPlayAtIndex(
              new Random().nextInt(assetsAudioPlayer!.playlist!.audios.length));
        } else if (!assetsAudioPlayer!.current.value!.hasNext &&
            assetsAudioPlayer!.currentLoopMode!.index == 2) {
          assetsAudioPlayer!.playlistPlayAtIndex(0);
        }
      }
    });
  }

  //添加音乐
  Future<Audio?> newAddAudio({required dynamic songinfo,required String? playurl,required String? suffix , bool isdrive=false, dynamic driveinfo, required String songSource})async{
    //计算歌曲唯一性
    //无缓存则从网络播放
    Audio? audio;
    String? simpleMusicGenerateSha1;
      simpleMusicGenerateSha1 = MusicCach.simpleMusicGenerateSha1(
          MusicName: songinfo["songName"],
          MusicAlbum: songinfo["album"],
          MusicArtists: songinfo["artist"],
          MusicSongSour: songSource);








    //判断是不是正在播放的歌曲
    if (assetsAudioPlayer!.current.hasValue) {
      if (assetsAudioPlayer!.current.hasValue&&assetsAudioPlayer!.current.value!=null&&assetsAudioPlayer!.current.value!.audio!= null) {
        if (simpleMusicGenerateSha1 ==
            assetsAudioPlayer!.current.value!.audio.audio.metas.id) {
          print('同一个音乐不操作');
          return null;
        } else {
          //是播放列表中的歌曲则世界跳转到该歌曲
          for (var element in assetsAudioPlayer!.playlist!.audios) {
            if (simpleMusicGenerateSha1 == element.metas.id) {
              print(
                  simpleMusicGenerateSha1 == element.metas.id);
              //不新增直接跳转到已经有的歌曲
              assetsAudioPlayer!.playlistPlayAtIndex(
                  assetsAudioPlayer!.playlist!.audios.indexOf(element));
              return null;
            }
          }
        }
      }
    }
    //是新增加的歌曲则开始播放
    //查看是否有缓存
    var searcachfile;
    try {
       searcachfile = MusicCach.searcachfile(simpleMusicGenerateSha1);
    } catch (e) {
      searcachfile=null;
    }
    //是否开启了缓存播放
    try {
      if(SpUtil.getBool(SetKey.CACHE_PLAY)!){
            if(isdrive){
             await AliClient.downloadFile(driveinfo["song"]["download_url"]!, driveinfo["song"]["size"].toString(), MusicCach.directory!.path, simpleMusicGenerateSha1);
            }else{
            await MusicCach.cachfile(playurl!, simpleMusicGenerateSha1);
            }
            searcachfile = MusicCach.searcachfile(simpleMusicGenerateSha1);
          }
    } catch (e) {
      searcachfile=null;
    }
    if (searcachfile == null) {
        //是否是云盘音乐
      if(isdrive){
        audio = Audio.network(
          driveinfo["song"]["download_url"]!,
          headers: {
            'referer': 'https://www.aliyundrive.com/',
            'Range': 'bytes=0-${driveinfo["song"]["size"].toString()}',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
            'Authorization': 'Bearer ' + AliClient.authorization,
          },
          metas: Metas(
            id: simpleMusicGenerateSha1,
            title: songinfo["songName"],
            artist: songinfo["artist"],
            album: songinfo["artist"],
            image: MetasImage.network(songinfo["pic"]),
          ),
          cached: false,
        );
      }else{
        audio = Audio.network(
          playurl!,
          metas: Metas(
            id: simpleMusicGenerateSha1,
            title: songinfo["songName"],
            artist: songinfo["artist"],
            album: songinfo["artist"],
            image: MetasImage.network(songinfo["pic"]),
          ),
          cached: false,
        );
      }




    }else{
      //从本地加载播放
      audio = Audio.file(
        searcachfile.path,
        metas: Metas(
          id: simpleMusicGenerateSha1,
          title: songinfo["songName"],
          artist: songinfo["artist"],
          album: songinfo["artist"],
          image: MetasImage.network(songinfo["pic"]),
        ),
      );
      //添加歌曲到播放列表
    }
    // assetsAudioPlayer!.open(audios!,
    //     autoStart: true,
    //     playInBackground: PlayInBackground.enabled,
    //     showNotification: true,
    //     notificationSettings: NotificationSettings(
    //       stopEnabled: false,
    //     ),
    //     loopMode: LoopMode.playlist);
    //播放器为空时创建一个

    //播放当前歌曲
    try {
      if (assetsAudioPlayer!.playlist!.audios.contains(audio)) {
            await assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.indexOf(audio));
          } else {
            //添加到列表中
            audios!.add(audio);
            assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.length - 1);
          }
    } catch (e) {
      // (空检查真操蛋)
      audios!.add(audio);
      assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.length - 1);
      await assetsAudioPlayer!.open(audios!,
          autoStart: true,
          playInBackground: PlayInBackground.enabled,
          showNotification: true,
          notificationSettings: NotificationSettings(
            stopEnabled: false,
          ),
          loopMode: LoopMode.playlist);
      onInitsd();
    }
    return audio;
  }


  /// 添加音乐
  ///[isnet] 当它为true时 [playurl]指的是 网络地址 否则为 本地地址路径
  ///[isplay] 是否播放当前添加歌曲 true为播放
  ///[source]为歌曲的来源 酷我 之类的
  // Future<bool?> addAudio(String playurl, String songname, String artist,
  //     String album, String imageurl, String source, String id,
  //     {bool isplay = true,
  //     // bool,
  //     String? suffix,
  //     bool isdrive = false,
  //     String? musuic_size}) async {
  //
  //   var audiosuffix;
  //   bool isopenover =false;
  //   if (isdrive) {
  //     audiosuffix = suffix;
  //   } else {
  //     var lastIndexOf = playurl.lastIndexOf(".");
  //     audiosuffix = playurl.substring(lastIndexOf, playurl.length);
  //   }
  //   //计算歌曲唯一性
  //   String simpleMusicGenerateSha1 = MusicCach.simpleMusicGenerateSha1(
  //       MusicName: songname,
  //       MusicAlbum: album,
  //       MusicArtists: artist,
  //       MusicSongSour: source);
  //   Audio? audio ;
  //   //云盘歌曲也是通过网络获得
  //   //查看是否是重复音乐（重复音乐不添加，当前播放的音乐不切换）
  //   try {
  //     if (assetsAudioPlayer!.current.hasValue) {
  //       if (assetsAudioPlayer!.current.value!.audio != null) {
  //         if (simpleMusicGenerateSha1 ==
  //             assetsAudioPlayer!.current.value!.audio.audio.metas.id!
  //                 .split(",")[0]) {
  //           print('同一个音乐不操作');
  //           return true;
  //         } else {
  //           //判断是不是已经播放的歌曲
  //           for (var element in assetsAudioPlayer!.playlist!.audios) {
  //             if (simpleMusicGenerateSha1 == element.metas.id!.split(",")[0]) {
  //               print(
  //                   simpleMusicGenerateSha1 == element.metas.id!.split(",")[0]);
  //               //不新增直接跳转到已经有的歌曲
  //               assetsAudioPlayer!.playlistPlayAtIndex(
  //                   assetsAudioPlayer!.playlist!.audios.indexOf(element));
  //               return true;
  //             }
  //           }
  //         }
  //       }
  //     }
  //   } catch (e) {}
  //
  //   //查看是否有缓存
  //   var searcachfile =
  //        MusicCach.searcachfile(simpleMusicGenerateSha1 + suffix!);
  //   //todo 目前插件有问题无法缓存播放 所以稍后用省流量模式
  //   //没有缓存
  //   // if(searcachfile==null){
  //   //   //将歌曲文件进行缓存
  //   //   String cachfile = await MusicCach.cachfile(playurl,simpleMusicGenerateSha1+suffix);
  //   //   audio = Audio.file(cachfile,
  //   //     metas: Metas(
  //   //       id: OtherUtils.generateMd5(playurl),
  //   //       title: songname,
  //   //       artist: artist,
  //   //       album: album,
  //   //       image: MetasImage.network(imageurl),
  //   //     ),
  //   //   );
  //   // }
  //
  //   if (searcachfile == null) {
  //     // //将歌曲文件进行缓存
  //     //todo 开启低消耗模式
  //
  //
  //     if(isopenover){
  //       await  MusicCach.cachfile(playurl,simpleMusicGenerateSha1+suffix);
  //       audio = Audio.file(
  //         searcachfile!.path,
  //         metas: Metas(
  //           id: simpleMusicGenerateSha1 + "," + source + "," + id,
  //           title: songname,
  //           artist: artist,
  //           album: album,
  //           image: MetasImage.network(imageurl),
  //         ),
  //       );
  //
  //     }else{
  //       //根据文件类型选择播放工具
  //       if (isdrive) {
  //         //是云盘歌曲
  //         //  await Client.downloadFile(playurl, musuic_size, MusicCach.directory.path, simpleMusicGenerateSha1+suffix);
  //         //  searcachfile = MusicCach.searcachfile(simpleMusicGenerateSha1 + suffix);
  //         // // print(downloadUrl.data);
  //         //  audio = Audio.file(
  //         //    searcachfile.path,
  //         //    metas: Metas(
  //         //      id: simpleMusicGenerateSha1 + "," + source + "," + id,
  //         //      title: songname,
  //         //      artist: artist,
  //         //      album: album,
  //         //      image: MetasImage.network(imageurl),
  //         //    ),
  //         //  );
  //
  //         audio = Audio.network(
  //           playurl,
  //           headers: {
  //             'Authorization': 'Bearer ' + AliClient.authorization!,
  //             "Referer": "https://www.aliyundrive.com/",
  //             "RANGE": "bytes=0-$musuic_size"
  //           },
  //           metas: Metas(
  //             id: simpleMusicGenerateSha1 + "," + source + "," + id,
  //             title: songname,
  //             artist: artist,
  //             album: album,
  //             image: MetasImage.network(imageurl),
  //           ),
  //           cached: false,
  //         );
  //         // print(audio.metas);
  //       } else {
  //         //普通歌曲
  //         audio = Audio.network(
  //           playurl,
  //           metas: Metas(
  //             id: simpleMusicGenerateSha1 + "," + source + "," + id,
  //             title: songname,
  //             artist: artist,
  //             album: album,
  //             image: MetasImage.network(imageurl),
  //           ),
  //           cached: false,
  //         );
  //       }
  //
  //     }
  //
  //
  //
  //
  //
  //   } else {
  //     //有缓存则播放缓存文件
  //     audio = Audio.file(
  //       searcachfile.path,
  //       metas: Metas(
  //         id: simpleMusicGenerateSha1 + "," + source + "," + id,
  //         title: songname,
  //         artist: artist,
  //         album: album,
  //         image: MetasImage.network(imageurl),
  //       ),
  //     );
  //   }
  //
  //   //判断是否是已经在歌单中的
  //   // try {
  //   //
  //   //   assetsAudioPlayer.playlist.audios.forEach((element) {
  //   //     if(element.metas.id.split("，")[0]==){
  //   //
  //   //     }
  //   //
  //   //
  //   //
  //   //   });
  //   //
  //   //   if(assetsAudioPlayer.playlist.audios.{
  //   //           //在则直接跳转到指定歌曲中
  //   //           assetsAudioPlayer.playlistPlayAtIndex(assetsAudioPlayer.playlist.audios.indexOf(audio));
  //   //           return true;
  //   //         }
  //   // } catch (e) {
  //   // }
  //
  //   //播放器为空时创建一个
  //   if (assetsAudioPlayer!.playlist == null) {
  //     audios = new Playlist();
  //     audios!.add(audio);
  //     await assetsAudioPlayer!.open(audios!,
  //         autoStart: true,
  //         playInBackground: PlayInBackground.enabled,
  //         showNotification: true,
  //         notificationSettings: NotificationSettings(
  //           stopEnabled: false,
  //         ),
  //         loopMode: LoopMode.values[SpUtil.getInt(SetKey.PLAY_SONG_LOOP)!]);
  //   }
  //
  //   if (assetsAudioPlayer!.playlist!.audios.contains(audio)) {
  //     await assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.indexOf(audio));
  //   } else {
  //     audios!.add(audio);
  //     if (isplay) {
  //       assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.length - 1);
  //       // await playAudio();
  //     } else {
  //       assetsAudioPlayer!.playlistPlayAtIndex(audios!.audios.length - 1);
  //     }
  //   }
  // }

  //从列表中移除音乐
  void removeAudio(Audio audio) {
    audios!.audios.remove(audio);
  }

  //通过下标移除
  void removeAudioAtIndex(int index) {
    audios!.removeAtIndex(index);
  }

  //暂停音乐
  bool? pauseAudio() {
    assetsAudioPlayer!.pause();
    isPlaying.value = false;
  }

  //播放音乐
  void playAudio() async {
    await assetsAudioPlayer!.play();
  }

  //播放列表
  audioList() {
    return audios;
  }

  //当前播放歌曲
  Audio playingAudio() {
    return assetsAudioPlayer!.current.value!.audio.audio;
  }

//跳转到指定位置
  seek(Duration duration) {
    // if(){
    //
    // }
    assetsAudioPlayer!.seek(duration);
  }

  void nextmusic() async{
    // await assetsAudioPlayer!.pause();
    if (assetsAudioPlayer!.currentLoopMode!.index == 0) {
     // await newAddAudio(songinfo: {}, playurl: "", suffix: "", songSource: "");
      // await   assetsAudioPlayer!.playlistPlayAtIndex(
   //        new Random().nextInt(assetsAudioPlayer!.playlist!.audios.length));
    } else if (!assetsAudioPlayer!.current.value!.hasNext &&
        assetsAudioPlayer!.currentLoopMode!.index == 2) {
      assetsAudioPlayer!.playlistPlayAtIndex(0);
    }else{
     await assetsAudioPlayer!.next();
     await assetsAudioPlayer!.play();
    }
  }

  //工具 Duration时间转字符串
  String MuisicDurationtoString(Duration duration) {
    DateTime dateTime =
        new DateTime(0, 0, 0, 0, 0, 0, 0, duration.inMicroseconds);
    return _dateFormat.format(dateTime);
  }

  AssetsAudioPlayer? get assetsAudioPlayer {
    if (_assetsAudioPlayer == null) {
      _assetsAudioPlayer = AssetsAudioPlayer.withId("sqmusic");
    }
    return _assetsAudioPlayer;
  }

  bool isCurrentPlayingMusic({required dynamic songinfo,required String songSource}) {
    String simpleMusicGenerateSha1 = MusicCach.simpleMusicGenerateSha1(
        MusicName: songinfo["songName"],
        MusicAlbum: songinfo["album"],
        MusicArtists: songinfo["artist"],
        MusicSongSour: songSource);

    try {
      return assetsAudioPlayer!.current.value!.audio.audio.metas.id! ==
          simpleMusicGenerateSha1
          ? true
          : false;
    } catch (e) {
      return false;
    }
  }
}
