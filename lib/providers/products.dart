import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shop/providers/product.dart';
import 'package:shop/models/http_exception.dart';

const String kUrl = 'https://shopacademine.firebaseio.com/products.json';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    //const String kUrl = 'https://shopacademine.firebaseio.com/products.json';
    try {
      final response = await http.get(kUrl);
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: productData['isFavorate'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (onError) {
      throw onError;
    }
  }

  Future<void> addProduct(Product product) async {
    //const String kUrl = 'https://shopacademine.firebaseio.com/products.json';
    try {
      final response = await http.post(
        kUrl,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavorate': product.isFavorite,
        }),
      );
      if (response != null) {
        final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name'],
        );
        _items.add(newProduct);
      }
      //_items.insert(0, newProduct);  // at the start of the list
      notifyListeners();
    } catch (onError) {
      print(onError);
      throw onError;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      try {
        final String url =
            'https://shopacademine.firebaseio.com/products/$id.json';
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
            }));
        _items[productIndex] = newProduct;
        notifyListeners();
      } catch (onError) {
        throw onError;
      }
    } else {
      print('Product Index value $productIndex');
    }
  }

  Future<void> removeProduct(String id) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      try {
        final String url =
            'https://shopacademine.firebaseio.com/products/$id.json';
        final response = await http.delete(url);
        if (response != null && response.statusCode == 200) {
          //print(json.decode(response.statusCode.toString()));
          _items.removeWhere((element) => element.id == id);
          notifyListeners();
        } else {
          throw HttpException('Something went wrong');
        }
      } catch (onError) {
        throw onError;
      }
    } else {
      print('Product Index value $productIndex');
    }
  }
}
