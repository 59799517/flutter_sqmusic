
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:sp_util/sp_util.dart';
import 'package:sqmusic/alidrive/AliClient.dart';
import 'package:sqmusic/set/SetKey.dart';
import 'package:sqmusic/utils/DBUtil.dart';
import 'package:sqmusic/utils/ToastUtil.dart';

class CheckToken extends StatefulWidget{
  const CheckToken({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>_CheckToken();

}
class _CheckToken extends State<StatefulWidget>{
  TextEditingController? _controller;

  var res_token = "".obs;
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child:Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _controller,
                      keyboardType: TextInputType.text,
                      maxLines: 4,
                      //不限制行数
                      /// 设置字体
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        //提交

                        res_token.value =value;
                        chenkAliToken().then((){
                          Get.back();
                        });

                      },
                      onChanged: (value){
                        res_token.value =value;
                      },

                      /// 设置输入框样式
                      decoration: InputDecoration(
                        // icon: Icon(LineIcons.cloud),
                        border: OutlineInputBorder(),
                        // suffixIcon: Icon(Icons.search),
                        // prefixText: 'prefixText ',
                        // suffixText: 'suffixText',
                        labelText: "阿里云盘token",
                        // helperText: '阿里云盘token',
                        // hintText: "用户名或手机号",
                        // prefixIcon: Icon(LineIcons.cloud)
                      ),
                    ),
                    SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GFButton(
                          type: GFButtonType.outline,
                          shape: GFButtonShape.pills,
                          textStyle: TextStyle(color: Colors.black),
                          onPressed: (){
                            // chenkAliToken(res_token.value);
                            chenkAliToken().then((sa){
                              Get.offAndToNamed("/home",arguments: 2);
                            });

                          },text: "确定",),
                        Container(),
                        GFButton(
                          type: GFButtonType.outline,
                          shape: GFButtonShape.pills,
                          textStyle: TextStyle(color: Colors.black),
                          onPressed: (){
                            Get.offAndToNamed("/home",arguments: 2);
                          },text: "取消",)
                      ],
                    )
                  ],
                ),
              ),
            ),
        ),
      );

  }

  chenkAliToken() async{
    var bool=false;
    SpUtil.putString(SetKey.REFRESH_TOKEN, res_token.value);
    try {
      bool = await AliClient.refreshToken();
      if(!bool){
        SpUtil.putBool(SetKey.OPEN_ALIDRIVE, false);
        await SpUtil.remove(SetKey.REFRESH_TOKEN);
      }else{
        SpUtil.putBool(SetKey.OPEN_ALIDRIVE, true);
        await SpUtil.putString(SetKey.REFRESH_TOKEN, res_token.value);
        OtherUtils.showToast(bool?"登录成功":"登录失败");
        return bool;
      }
    } catch (e) {
      await SpUtil.putBool(SetKey.OPEN_ALIDRIVE, false);
      await SpUtil.remove(SetKey.REFRESH_TOKEN);
    }
    OtherUtils.showToast(bool?"登录成功":"登录失败");
  }

  @override
  void initState() {
    if(SpUtil.containsKey(SetKey.REFRESH_TOKEN)!){
      res_token.value = SpUtil.getString(SetKey.REFRESH_TOKEN)!;
    }
    _controller = new TextEditingController(text: res_token.value);

  }
}