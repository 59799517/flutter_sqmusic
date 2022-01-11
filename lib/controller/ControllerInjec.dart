import 'package:get/get.dart';
import 'package:sqmusic/controller/AliDriveController.dart';
import 'package:sqmusic/controller/KuwoController.dart';
import 'package:sqmusic/controller/MusicPlayController.dart';


/**
 * 依赖注入
 */
class ControllerInjec extends GetxController{


  injec(){
    Get.put(MusicPlayController(),permanent: true);
    Get.put(KuwoController(),permanent: true);
    Get.put(AliDriveController(),permanent: true);

  }



}