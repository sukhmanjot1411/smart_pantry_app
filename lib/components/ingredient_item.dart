import 'package:flutter/material.dart';

class IngredientItem extends StatelessWidget {
  final String quantity,measure,food,imageUrl;
  //final List<Map<String, dynamic>> ingredients;

  const IngredientItem({super.key,
    required this.quantity,
    required this.food,
    required this.measure,
    required this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
    final h=MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.symmetric(vertical: h*.01,horizontal: w*.033),
      padding:// EdgeInsets.all(h*.02),
      EdgeInsets.only(
        top: h*.008, bottom: h*.008, left: h*.008, right: w*.08
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(.2),
              blurRadius: 5,spreadRadius: 2,
              offset: const Offset(0,3)
          ),
        ],
      ),
      child: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Space children apart
        //crossAxisAlignment: CrossAxisAlignment.center,      // Vertically align children

        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imageUrl,width: w*0.2,height: h*0.1,fit: BoxFit.cover,),
            //Image.asset('assets/back.png', width: w * 0.2, height: h * 0.1, fit: BoxFit.cover),
          ),
          SizedBox(width: w * 0.033),
          Flexible(
            child: Text("$food\n$quantity $measure", style: TextStyle(
                fontSize: w*.04,fontWeight: FontWeight.bold,letterSpacing: 1
            ),),
          ),
          SizedBox(width: w*.033,),
          Icon(Icons.add_circle_outline_rounded,size: w*.07,color: Colors.orangeAccent,)
        ],


    ),
    );
  }
}



