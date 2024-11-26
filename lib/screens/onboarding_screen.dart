import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:recipe_app_final/constants/images_path.dart';
import 'package:recipe_app_final/constants/images_path.dart';

import 'home.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h=MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;


    return Scaffold(
      body: SizedBox(
        height: h,
        width: w,
        child: Stack(
          children: [
            Positioned(
                top:0,
                child: Container(
                  height: h*.79,
                  width: w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImagesPath.onBoardingTitle),
                      fit: BoxFit.cover
                    )
                  )
                )),
            // Center(
            //   child: Image.asset(ImagesPath.onBoardingTitle),
            //
            // ),
            Positioned(
                bottom: 0,
                child: Container(
                    height:h*.243,
                    width: w,
                    decoration: BoxDecoration(
                        color: Colors.grey[350],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                            //bottomLeft: Radius.circular(40),
                            //bottomRight: Radius.circular(40)
                        ),
                    ),
                  child: Padding(
                    padding: EdgeInsets.only(top: h*.032),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      
                          Text('Lets cook some good food' ,style: TextStyle(
                            fontSize: w*0.06,fontWeight: FontWeight.w600
                          ),),
                          SizedBox(height:h*.01,),
                          Text('Try the app now !',
                          style: TextStyle(
                            fontSize: 18,fontWeight : FontWeight.w400
                          ),),

                          SizedBox(height: h*.032,),
                          SizedBox(
                            width: w*.8,
                            child: ElevatedButton(
                              onPressed: (){
                                Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context)=>Home()));
                              },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFF49619), // Background color
                                ),
                              child: const Text('Get Started',style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold
                              ),)
                            ),

                          )

                        ]
                      
                      
                      ),
                    )

                  )
                )
            ))

          ],

    )

      )
    );
  }
}
