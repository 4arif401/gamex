import 'package:get/get.dart';

class UserController extends GetxController {
  RxString userId = ''.obs;
  RxString email = ''.obs;
  RxString displayName = ''.obs;
  RxString rank = ''.obs;
  RxString phone = ''.obs;
  RxString password = ''.obs;

  void updateUser(Map<String, dynamic> userData) {
    userId.value = userData['user_id'];
    email.value = userData['email'];
    displayName.value = userData['display_name'];
    rank.value = userData['rank'];
    phone.value = userData['phone'];
    password.value = userData['password'];
  }

  void afterUpdate(String displayname, String emailu, String phoneu) {
    email.value = emailu;
    displayName.value = displayname;
    phone.value = phoneu;
  }
}
