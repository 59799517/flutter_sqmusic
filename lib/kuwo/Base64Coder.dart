// ignore_for_file: non_constant_identifier_names, avoid_types_as_parameter_names

import 'dart:convert';
import 'dart:ffi';
import 'dart:ffi';

import 'dart:math';

import 'package:flutter/material.dart';

class Base64Coder{

  static List<String>? map1 ;
  //不会初始化
  static bool isinit=false;
//  }
//   static {
//   int i = 0;
//   for (char c = 'A'; c <= 'Z'; c++)
//   map1[i++] = c;
//   for (char c = 'a'; c <= 'z'; c++)
//   map1[i++] = c;
//   for (char c = '0'; c <= '9'; c++)
//   map1[i++] = c;
//   map1[i++] = '+';
//   map1[i++] = '/';
// }


  static List<String> encode( List<int> ins, int iLen, String key) {
     //第一次初始化
     if(map1==null){
       map1 =  List.filled(64, "",growable: false);
         int i = 0;
         for (int c = 'A'.codeUnitAt(0); c <= 'Z'.codeUnitAt(0); c++)
           map1![i++] = String.fromCharCode(c);
         for (int c = 'a'.codeUnitAt(0); c <= 'z'.codeUnitAt(0); c++)
           map1![i++] = String.fromCharCode(c);
         for (int c = '0'.codeUnitAt(0); c <= '9'.codeUnitAt(0); c++)
           map1![i++] = String.fromCharCode(c);
         map1![i++] = '+';
         map1![i++] = '/';
     }



  // 如果key不为空，则按位与key异或
  if (key != null && key.isNotEmpty) {
  List<int>keyArr =utf8.encode(key);
  for (int i = 0; i < ins.length;) {
  for (int j = 0; j < keyArr.length && i < ins.length; j++) {
  ins[i++] ^= keyArr[j];
  }
  }
  }

  int oDataLen = ((iLen * 4 + 2) / 3) .truncate(); // output length without padding
  int oLen = (((iLen + 2) / 3) * 4) .truncate(); // output length including padding
  List<String> out = List.filled(oLen, "",growable: false);
  int ip = 0;
  int op = 0;
  while (ip < iLen) {
  int i0 = ins[ip++] & 0xff;
  int i1 = ip < iLen ? ins[ip++] & 0xff : 0;
  int i2 = ip < iLen ? ins[ip++] & 0xff : 0;
  int o0 = i0 >>> 2;
  int o1 = ((i0 & 3) << 4) | (i1 >>> 4);
  int o2 = ((i1 & 0xf) << 2) | (i2 >>> 6);
  int o3 = i2 & 0x3F;
  out[op++] = map1![o0];
  out[op++] = map1![o1];
  out[op] = op < oDataLen ? map1![o2] : '=';
  op++;
  out[op] = op < oDataLen ? map1![o3] : '=';
  op++;
  }
  return out;
  }
  static List<String> encode1( List<int>  ins, int iLen) {
  return encode(ins, iLen, "");
  }
}