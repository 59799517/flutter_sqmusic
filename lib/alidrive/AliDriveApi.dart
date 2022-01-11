import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;


import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'dart:convert' as convert;


//阿里上传api
class AliDriveApi {
  static Dio dio = new Dio();
  static String ua =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36";
  ///刷新token 获取token
  static Future<Response> refreshToken(String refresh_token) async {
    var jsonEncode = convert.jsonEncode({"refresh_token": refresh_token});
    Response post = await dio.post(
        "https://websv.aliyundrive.com/token/refresh",
        data: jsonEncode,
        options: Options(headers: {"User-Agent": ua}));

    return post;
  }
  //用户信息
  static Future<Response> userinfo(String authorization) async{
    var headers = {
      'User-Agent': ua,
      'Authorization': 'Bearer ' + authorization,
      'Content-Type': 'application/json',
    };
    var parse = Uri.parse('https://api.aliyundrive.com/v2/user/get');
    var body={};
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    print(postUri);
    return postUri;
  }
  //


  ///获取文件列表
  static Future<Response> fileList(
      String authorization, String drive_id, String path_id) async {
    var headers = {
      'User-Agent': ua,
      'Authorization': 'Bearer ' + authorization,
      'Content-Type': 'application/json',
    };
    var parse = Uri.parse('https://api.aliyundrive.com/v2/file/list');
    var body = {
      "drive_id": drive_id,
      "parent_file_id": path_id,
      "limit": 200,
      "all": true,
      "url_expire_sec": 1600,
      "image_thumbnail_process": "image/resize,w_400/format,jpeg",
      "image_url_process": "image/resize,w_1920/format,jpeg",
      "video_thumbnail_process": "video/snapshot,t_0,f_jpg,ar_auto,w_800",
      "fields": "*",
      "order_by": "updated_at",
      "order_direction": "DESC"
    };
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    return postUri;
  }

  //重命名文件
  static Future<Response> rename(String authorization, String drive_id,{required file_id,required name}) async{
    var headers = {
      'User-Agent': ua,
      'Authorization': 'Bearer ' + authorization,
      'Content-Type': 'application/json',
    };
    var parse = Uri.parse('https://api.aliyundrive.com/v3/file/update');
    var body ={"drive_id":"178606","file_id":file_id,"name":name,"check_name_mode":"refuse"};
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    return postUri;
  }


  ///搜索文件
  ///[name] 文件名称
  ///[file_extension] 文件类型
  static Future<Response> Search(
      String authorization, String drive_id, String path_id,{String? name,String? file_extension}) async {
    var headers = {
      'User-Agent': ua,
      'Authorization': 'Bearer ' + authorization,
      'Content-Type': 'application/json',
    };
    var parse = Uri.parse('https://api.aliyundrive.com/v2/file/search');

    String query = "parent_file_id = \"$path_id\"";
    if(name!=null){
      query += "and name match \"$name\"";
    }
    if(file_extension!=null){
      query += "and file_extension = \"$file_extension\"";
    }
    var body={
        {
          "drive_id": drive_id,
          "limit": 100,
          "query": query,
          "image_thumbnail_process": "image/resize,w_160/format,jpeg",
          "image_url_process": "image/resize,w_1920/format,jpeg",
          "video_thumbnail_process": "video/snapshot,t_0,f_jpg,ar_auto,w_300",
          "order_by": "updated_at DESC"
        }
    };
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    return postUri;
  }


  //创建文件夹
  static Future<Response> mkdir(String authorization, String drive_id,
      String parent_file_id, String name) async {
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
      'Content-Type': 'application/json',
    };
    var parse = Uri.parse(
        'https://api.aliyundrive.com/adrive/v2/file/createWithFolders');
    var body = {
      "drive_id": drive_id,
      "parent_file_id": parent_file_id,
      "name": name,
      "check_name_mode": "refuse",
      "type": "folder"
    };
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    return postUri;
  }

  //上传文件
  static Future<Response> uploadFile(String authorization, String drive_id,
      String file_path, String name,String parent_file_id) async {
    var file = new File(file_path);
    var convert = sha1.convert(file.readAsBytesSync());
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
    };
    var parse = Uri.parse('https://api.aliyundrive.com/adrive/v2/file/create');
    var body = {
      "drive_id": drive_id,
      "name": name,
      "type": "file",
      "content_type": "application/json",
      "check_name_mode": "refuse",
      "content_hash": convert.toString(),
      "content_hash_name": "sha1",
      "size": checkFileSize(file_path),
      "ignoreError": "false",
      "parent_file_id": parent_file_id,
      "part_info_list ": [
        {"part_number": "1"}
      ]
    };
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body,
        onReceiveProgress: (int count, int total) {
    });
    if(postUri.data["exist"]==null){
      postUri.data["exist"]=false;
    }
    //无法快传  进行手动传
    if ( !postUri.data["exist"]&&!postUri.data["rapid_upload"]) {
      //获取手动上传链接
      // print(postUri.data["part_info_list"][0]["upload_url"]);
      // print(postUri.data["upload_id"]);

      var parse2 = Uri.parse(postUri.data["part_info_list"][0]["upload_url"]);

      var uploadheaders = {
        'accept': '*/*',
        'accept-language': 'zh-CN,zh;q=0.9,ja;q=0.8',
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.3',
        "connection": "keep-alive",
      };
      var putUri = await dio.putUri(parse2,
          data: file.openRead(),
          options: Options(
            headers: uploadheaders,
            contentType: "",
          ), onReceiveProgress: (int count, int total) {
        // print(count);
        // print(total);
      });
      // print(putUri.statusCode);
      // print(putUri.data);
      var completefile = await completeUpload(authorization, drive_id,
          postUri.data["file_id"], postUri.data["upload_id"]);
      // print(completefile.statusCode);
      // print(completefile);
    }
    return postUri;
  }

  //获取下载链接
  static Future<Response> get_download_url(
      String authorization, String drive_id, String file_id) async {
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
      'Content-Type': 'application/json',
    };
    var parse =
        Uri.parse('https://api.aliyundrive.com/v2/file/get_download_url');
    var body = {"drive_id": drive_id, "file_id": file_id};
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    return postUri;
  }


  static Future<String?> download_file_to_string(String authorization,url,size) async{
    // url="https://bj29.cn-beijing.data.alicloudccp.com/KowpCxnF%2F178606%2F61dc7a9d56249d501b9744349a48d9261947ce43%2F61dc7a9df8d9370fb7614b78abc897e8064f1ee1?di=bj29&dr=178606&f=61dc7a9d56249d501b9744349a48d9261947ce43&response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27test.txt&u=687d5434ce194cf3bbc44a2ca536ac7f&x-oss-access-key-id=LTAIsE5mAn2F493Q&x-oss-additional-headers=referer&x-oss-expires=1641840862&x-oss-signature=NReWveWhOGxbGxp%2BDYo8IsvUyPEhkE%2BZkEQ2YeRZ%2Fy4%3D&x-oss-signature-version=OSS2";
    // size="21014";
    var headers = {
      'referer': 'https://www.aliyundrive.com/',
      'Range': 'bytes=0-$size',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36',
      'Authorization': 'Bearer ' + authorization,
    };
    var request = http.Request('GET', Uri.parse(url));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {

     return await response.stream.bytesToString();
    }
    else {
    return null;
    }

  }

  //下载文件
  static Future<Response> download_file(
      String authorization,
      String download_url,
      String download_size,
      String download_path,
      String download_name) async {
    var parse = Uri.parse(download_url);
    //计算文件大小
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
      "Referer": "https://www.aliyundrive.com/",
      "Range": "bytes=0-$download_size"
    };
    Options options = Options(headers: headers);

    var downloadUri = await dio
        .downloadUri(parse, download_path + "/$download_name", options: options,
            onReceiveProgress: (count, total) {
      print(count);
      print(total);
    });
    // print(downloadUri);
    return downloadUri;
  }
//删除文件
  static Future<Response> del_file(
      String authorization, String drive_id, String file_id) async {
    var parse = Uri.parse('https://api.aliyundrive.com/v2/recyclebin/trash');
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
    };
    var body = {"drive_id": drive_id, "file_id": file_id};
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    // print(postUri);
    return postUri;
  }

  static Future<Response> completeUpload(String authorization, String drive_id,
      String file_id, String upload_id) async {
    var parse = Uri.parse('https://api.aliyundrive.com/v2/file/complete');
    var headers = {
      'Authorization': 'Bearer ' + authorization,
      'User-Agent': ua,
    };
    var body = {
      "drive_id": drive_id,
      "file_id": file_id,
      "upload_id": upload_id
    };
    Options options = Options(headers: headers);
    var postUri = await dio.postUri(parse, options: options, data: body);
    // print(postUri);
    return postUri;
  }

  static  int checkFileSize(String filepath){
    Directory directory = Directory(filepath);
    final file = new File(directory.path);
    return file.lengthSync();
  }
}
