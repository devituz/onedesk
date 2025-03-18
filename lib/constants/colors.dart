import 'dart:ui';

import 'package:flutter/material.dart';

class AppStyles {

  static const Color HomePage_backgound = Color(0xFF1F3262);
  static const Color HomePage_card_backgound = Colors.white;
  static const Color HomePage_icon_color = Colors.black;



  static const Color kok = Colors.blue;
  static const Color yashil = Color(0xFF00885A);
  static const Color yashilroq = Color(0xFFDAEDE7);
  static const Color yashqora = Color(0xFFDAEDE7);
  static const Color yashilsifat = Color(0xFF1A936A);
  static const Color orqa_fon = Color(0xFFE1F5FF);
  static const Color body_color_kun = Color(0xFF6D67E4);
  static const Color body_color_tun = Color(0xFF0B0E14);
  static const Color bottom_navigation = Color(0xFF614FE0);
  static const Color rangsifatroq = Color(0xFF191E29);

  static const Color otpqora =  Color(0xFF121212);
  static const Color boxdecoration =  Color(0xFFeceff6);
  static const Color otpqora1 =  Color(0xFF999A9D);
  static const Color containeroq =  Color(0xFFEEEFF3);
  static const Color select =  Color(0x94000000);
  static const Color home_rangsifatroq = Color(0xFF191A29);
  static const Color input = Color(0xFF2E3192);
  static const Color icon_colors = Color(0xFF4F82E0);
  static const Color qora = Colors.black;
  static const Color Login_text1 = Color(0xFF4F82E0);
  static const Color button_color = Color(0xff2e3192);
  static const Color oq = Color(0xffffffff);
  static const Color Button = Color(0xFF4F82E0);



  static final ButtonStyle LoginButton = ElevatedButton.styleFrom(
    backgroundColor: AppStyles.button_color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  );



  static final ButtonStyle LogoutButton = ElevatedButton.styleFrom(

    backgroundColor: AppStyles.button_color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    )

  );
  static final ButtonStyle DeleteButton = ElevatedButton.styleFrom(

    backgroundColor:Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    )

  );

  static final ButtonStyle SaveButton = ElevatedButton.styleFrom(

    backgroundColor: AppStyles.button_color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    )

  );


}



