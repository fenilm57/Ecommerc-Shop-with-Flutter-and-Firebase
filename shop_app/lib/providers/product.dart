import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleIsFavourite(String token, String userId) async {
    isFavourite = !isFavourite;
    notifyListeners();
    final url = Uri.parse(
        'https://flutter-shop-app-8e862-default-rtdb.firebaseio.com/userFavrite/$userId/$id.json?auth=$token');
    await http.put(
      url,
      body: json.encode(
        isFavourite,
      ),
    );
  }
}
