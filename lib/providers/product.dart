import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    var newFavorite = !isFavorite;
    try {
      final String url =
          'https://shopacademine.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
      final response = await http.put(url,
          body: json.encode(
            newFavorite,
          ));
      //print(json.decode(response.statusCode.toString()));
      if (response != null && response.statusCode == 200) {
        isFavorite = newFavorite;
        notifyListeners();
      } else {
        throw HttpException('Something went wrong');
      }
    } catch (onError) {
      throw onError;
    }
  }
}
