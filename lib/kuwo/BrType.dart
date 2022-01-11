import 'package:flutter/material.dart';

///2022/1/5
/// 编码类型
///   // aac：24，48 太低不要
//     // wma：96，128
//     // mp3：128，192，320
//     // ape：1000
//     // flac：2000
enum  BrType {
  wma96,
  wma128,
  mp3128,
  mp3192,
  mp3320,
  ape1000,
  flac2000
}