import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _auto;
  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    if (_auto != null) {
      _auto.cancel();
      _auto = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoLogout() {
    if (_auto != null) {
      _auto.cancel();
    }
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _auto = Timer(Duration(seconds: timeToExpire), logout);
  }

  Future<void> _authenticate(
      String email, String password, String segment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$segment?key=AIzaSyDZl67c0eeIGcZncICplKRSEqhMGhs4jKk');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      autoLogout();
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryData']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _expiryDate = expiryDate;
    _userId = extractedData['userId'];
    notifyListeners();
    autoLogout();
    return true;
  }

  Future<void> userSignIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> userSignUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }
}
