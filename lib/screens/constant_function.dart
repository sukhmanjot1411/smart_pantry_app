import 'dart:convert';

import 'package:http/http.dart' as http;
class ConstantFunction{

  static Future<List<Map<String,dynamic>>> getResponse(String findRecipe) async{
    String id='6fe977fe';
    String key='1662eafdf189bccb5a4c31082373c403';

    String api="https://api.edamam.com/search?q=$findRecipe&app_id=$id&app_key=$key&from=0&to=20&calories=591-722&health=alcohol-free";
    final response= await http.get(Uri.parse(api));
    List<Map<String,dynamic>> recipe=[];
    if(response.statusCode==200){

      var data = jsonDecode(response.body);

      if(data['hits']!=null){
        for(var hit in data['hits']){
          recipe.add(hit['recipe']);
        }
      }
      return recipe;

    }
    return recipe;
  }
}