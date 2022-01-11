import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqmusic/page/kuwo/widget/list_container.dart';


///酷我的listWidget
class TopListContainer extends StatefulWidget {
  //需要渲染的数据
  dynamic data;
  String? name;
  TopListContainer(this.data, this.name);

  @override
  State<StatefulWidget> createState() =>_TopListContainer(this.data, this.name);

}

class _TopListContainer extends State<TopListContainer>{
  //需要渲染的数据
  dynamic data;
  String? name;
  List<Widget>? list;

  _TopListContainer(this.data, this.name);

  Size? size;
  @override
  Widget build(BuildContext context) {
    size=MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
          right:size!.height*0.01,
          left: size!.height*0.01
      ),
      child: Column(
        //这里是名称和 更多按钮
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name!,style: TextStyle(fontSize: size!.height*0.025),),
                // TextButton(child: Text("更多>>>",style: TextStyle(fontSize: size.height*0.015  )),onPressed: (){
                //     //暂时点了没用
                // }
                // ),
              ],
            ),
          ),
          Container(
            // height: size.height*0.8,
            child:Wrap(
              direction: Axis.horizontal ,
              // spacing: size.height*0.00016, //chip之间的间隙大小
              // runSpacing: size.height*0.0001, //行之间的间隙大小
              children: list!,
            )
          )


        ],
      ),
    );
  }

  @override
  void initState() {
    list=[];
    for (var item in this.data) {
      var listContainer = ListContainer(item["name"],item["pic"],int.parse(item["sourceid"]));
      list!.add(listContainer);
    }
  }
}