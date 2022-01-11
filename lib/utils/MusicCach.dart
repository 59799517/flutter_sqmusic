import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqmusic/utils/RequestUtils.dart';



class MusicCach{


  static Directory? temporaryDirectory;
  // static Directory applicationDocumentsDirectory;
  static Directory? directory  ;
  // static Directory externalStorageDirectory;
  static Map<String ,String > lyrics = Map();
  static Map<String ,String > trans = Map();
  static Map<String ,dynamic > songinfo = Map();


  static initDirectory() async{
    // temporaryDirectory = await getTemporaryDirectory();
    // applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
    //  externalCacheDirectories = await getExternalCacheDirectories();
      directory = await getApplicationSupportDirectory();
      temporaryDirectory = await getTemporaryDirectory();
  }
  //缓存文件
  static Future<String?> cachfile(String uri,String filename) async{
    var response = await  RequestUtils.downloadFile(uri, filename);
    if(response.statusCode==200){
      return MusicCach.directory!.path+"/"+filename;
    }
  }

  // //缓存图片
  // static Future<String> cachimagefile(String uri,String filename) async{
  //   var response = await  RequestUtils.downloadFile(uri, filename);
  //   if(response.statusCode==200){
  //     return MusicCach.directory.path+"/"+filename;
  //   }
  // }
  //缓存数据
  static Future<String> cachjsonfile(String data,String filename) async{
      var file = new File(MusicCach.directory!.path+"/"+filename);
      file.createSync();
      file.writeAsStringSync(data);

      return MusicCach.directory!.path+"/"+filename;
  }

  //缓存数据
  static String readjsonfile(String filepath,filename) {
    var file = new File(filepath+"/"+filename);
    String contents =  file.readAsStringSync();
      return contents;
  }



  ///  查找缓存文件 存在则返回不存在返回null   384294700
  static Directory? searcachfile(String filename) {
    Directory directory = Directory(MusicCach.directory!.path+"/"+filename);
    final file = new File(directory.path);
    var existsSync = file.existsSync();
    if(existsSync){
      return directory;
    }
    return null;
  }


  // ///  查找缓存图片文件
  //     static Future<Directory> searcachimagefile(String filename) async{
  //   Directory directory = Directory(MusicCach.directory.path+"/img/"+filename);
  //   final file = new File(directory.path);
  //   var existsSync = file.existsSync();
  //   if(existsSync){
  //     return directory;
  //   }
  //   return null;
  // }
  // ///  查找缓存json文件
  // static Future<Directory> searcachjsonfile(String filename) async{
  //   Directory directory = Directory(MusicCach.directory.path+"/"+filename);
  //   final file = new File(directory.path);
  //   var existsSync = file.existsSync();
  //   if(existsSync){
  //     return directory;
  //   }
  //   return null;
  // }


  //递归计算文件、文件夹的大小
  static Future<double> getTotalSizeOfFilesInDir(
      final FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
        return double.parse(length.toString());
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  //计算缓存大小
  static String formatSize(double value) {
    if (null == value) {
      return '0';
    }
    List<String> unitArr =List.filled(4,"",growable: false)..add('B')..add('K')..add('M')..add('G');
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  // //获取文件夹缓存大小
  // static Future<double> loadApplicationCache() async {
  //   //获取文件夹
  //   Directory docDirectory = await getApplicationDocumentsDirectory();
  //   Directory tempDirectory = await getTemporaryDirectory();
  //
  //   double size = 0;
  //
  //   if (docDirectory.existsSync()) {
  //     size += await getTotalSizeOfFilesInDir(docDirectory);
  //   }
  //   if (tempDirectory.existsSync()) {
  //     size += await getTotalSizeOfFilesInDir(tempDirectory);
  //   }
  //   return size;
  // }
      //删除文件夹下所有文件、或者单一文件
  static Future<Null> deleteDirectory(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await deleteDirectory(child);
        await child.delete();
      }
    }
  }
  // 删除缓存
  // static void clearApplicationCache() async {
  //   // Directory docDirectory = await getApplicationDocumentsDirectory();
  //   // Directory tempDirectory = await temporaryDirectory();
  //   //
  //   // if (docDirectory.existsSync()) {
  //   //   await deleteDirectory(docDirectory);
  //   // }
  //
  //   if (temporaryDirectory.existsSync()) {
  //     await deleteDirectory(temporaryDirectory);
  //   }
  // }
///计算文件大小
  static  int checkFileSize(String filepath){
    Directory directory = Directory(filepath);
    final file = new File(directory.path);
   return file.lengthSync();
  }
  ///计算文件sha1值
  static  String generateSha1(String data){
   return sha1.convert(utf8.encode(data)).toString();
  }
  //计算字符串md5（统一使用sha1方便以后）
  // static String generateMd5(String data) {
  //   var content = new Utf8Encoder().convert(data);
  //   var digest = md5.convert(content);
  //   // 这里其实就是 digest.toString()
  //   return hex.encode(digest.bytes);
  // }
  static  String simpleMusicGenerateSha1({String? MusicName,String? MusicArtists,String? MusicAlbum,String? MusicSongSour}){
    return sha1.convert(utf8.encode("$MusicName/$MusicArtists/$MusicAlbum/$MusicSongSour")).toString();
    }






}