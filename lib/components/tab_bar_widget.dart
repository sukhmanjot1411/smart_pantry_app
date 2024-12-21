//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:recipe_app_final/screens/constant_function.dart';

import '../screens/detail_screen.dart';

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final h=MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;
    return DefaultTabController(
        length: 4, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          height: h*.06, 
          child: TabBar(
            unselectedLabelColor: Color(0xFFF49619),
            labelColor: Colors.white,
            dividerColor: Colors.white,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicator: BoxDecoration(
              color: Color(0xFFF49619),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF49619).withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 4),
            labelPadding: EdgeInsets.symmetric(horizontal: 4),
            tabs: const [
              TabItem(title: 'Breakfast'),
              TabItem(title: 'Lunch'),
              TabItem(title: 'Dinner'),
              TabItem(title: 'Quickies'),
            ],
          ),
        ),
        SizedBox(height: h*.02,),

        SizedBox(
          height: h*.3,
          child: TabBarView(
            children: [
              HomeTabBarView(recipe: 'breakfast'),
              HomeTabBarView(recipe: 'lunch'),
              HomeTabBarView(recipe: 'dinner'),
              HomeTabBarView(recipe: 'quick')
            ],
          ),
        )
      ],
    ));
  }
}
class TabItem extends StatelessWidget {
  final String title;
  const TabItem({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFFF49619),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Center(
          child: Text(
            title, 
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    return const Placeholder();
  }
}

class HomeTabBarView extends StatelessWidget {
  final String recipe;
  const HomeTabBarView({super.key,required this.recipe});

  @override
  Widget build(BuildContext context) {
    final h= MediaQuery.of(context).size.height;
    final w=MediaQuery.of(context).size.width;
    return SizedBox(
      height: h*.28,
        child: FutureBuilder(
          future: ConstantFunction.getResponse(recipe),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            else if(!snapshot.hasData){
              return const Center(
                child: Text('no data'),
              );
            }


            return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  Map<String,dynamic> snap= snapshot.data![index];
                  int time=snap['totalTime'].toInt();
                  int calories=snap['calories'].toInt();
                  return Container(
                    margin: EdgeInsets.only(
                      right:w*.02
                    ),
                    width: w*.5,
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           GestureDetector(
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context)=>
                                        DetailScreen(item: snap ,)));
                              },
                             child: Container(
                                width: w,
                                height: h*.17,
                                decoration: BoxDecoration(
                                  borderRadius:  BorderRadius.circular(15),
                                  image: DecorationImage(image: NetworkImage(snap['image']),
                                  fit: BoxFit.fill)
                                ),
                              ),
                            ),
                            SizedBox(height: h*.01,),
                            Text(snap['label'], style: TextStyle(
                              fontSize: w*.035,
                              fontWeight: FontWeight.bold
                            ),),
                            SizedBox(height: h*.01,),
                            Text("calories: ${calories.toString()} . Time: ${time.toString()} Min", style: TextStyle(
                              fontSize: w*.03,color: Colors.grey
                            ),)
                          ],
                        )
                      ],
                    ),

                  );

                },
                separatorBuilder: (context,index){
                  return const SizedBox(width: 15,);
                },
                itemCount: snapshot.data!.length

            );
        },
        )

    );
  }
}
