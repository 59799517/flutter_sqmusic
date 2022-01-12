// @dart=2.9
import 'lyric.dart';

class LyricUtil {
  static Map Lyrics=Map();

  static var tags = ['ti', 'ar', 'al', 'offset', 'by'];

  /// 格式化歌词
  static List<Lyric> formatLyric(String lyricStr) {
    if (lyricStr == null || lyricStr.trim().length == 0) {
      return null;
    }
    lyricStr = lyricStr.replaceAll("\r", "");
    RegExp reg = RegExp(r"""\[(.*?):(.*?)\](.*?)\n""");

    Iterable<Match> matches;
    try {
      matches = reg.allMatches(lyricStr);
    } catch (e) {
      print(e.toString());
    }

    List<Lyric> lyrics = [];
    List list = matches.toList();
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        var temp = list[i];
        var title = temp[1];
        if (!tags.contains(title)) {
          lyrics.add(
            Lyric(
              list[i][3],
              startTime: lyricTimeToDuration(
                "${temp[1]}:${temp[2]}",
              ),
            ),
          );
        }
      }
    }
    //移除所有空歌词
    lyrics.removeWhere((lyric) => lyric.lyric.trim().isEmpty);
    for (int i = 0; i < lyrics.length - 1; i++) {
      lyrics[i].endTime = lyrics[i + 1].startTime;
    }
    lyrics.last.endTime = Duration(hours: 200);
    return lyrics;
  }

  static Duration KugoulyricTimeToDuration(String time){
    var split = time.split(".");
    int seconds =0 ;
    try {
      seconds=int.parse(split[0]);
    } catch (e) {
      seconds=0;
    }
    int microseconds =0 ;
    try {
      microseconds=int.parse(split[1]);
    } catch (e) {
      microseconds=0;
    }
    //分
    int minute =0;
    try {
      minute=(seconds/60).truncate();
    } catch (e) {
      minute=0;
    }
    //秒
    seconds=seconds%60;
    //微秒
  int  milliseconds =0;
    //毫秒
    microseconds=int.parse(split[1]);
    milliseconds = (microseconds/1000).truncate();
    microseconds=microseconds%1000;
    return Duration(minutes: minute,seconds: seconds,milliseconds: milliseconds,microseconds: microseconds);
  }

  static Duration lyricTimeToDuration(String time) {
    int minuteSeparatorIndex = time.indexOf(":");
    int secondSeparatorIndex = time.indexOf(".");

    // 分
    var minute = time.substring(0, minuteSeparatorIndex);
    // 秒
    var seconds =
        time.substring(minuteSeparatorIndex + 1, secondSeparatorIndex);
    // 微秒
    var millsceconds = time.substring(secondSeparatorIndex + 1);
    var microseconds = '0';
    // 判断是否存在微秒
    if (millsceconds.length > 3) {
      // 存在微秒 重新给予赋值
      microseconds = millsceconds.substring(3);
      millsceconds = millsceconds.substring(0, 3);
    }

    return Duration(
        minutes: int.parse(minute),
        seconds: int.parse(seconds),
        milliseconds: int.parse(millsceconds),
        microseconds: int.parse(microseconds));
  }
  static  List<Lyric> formatLyricByKuwo(List<dynamic>  data){
    List<Lyric> lyrics = [];
    for(int i=0;i<data.length;i++){
      lyrics.add(Lyric(
        data[i]["lineLyric"],
        startTime: KugoulyricTimeToDuration(data[i]["time"]),
        endTime:i==data.length-1?KugoulyricTimeToDuration(data[i]["time"]):KugoulyricTimeToDuration(data[i+1]["time"])
      ));
    }
    return lyrics;
  }
}
