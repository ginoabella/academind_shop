import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop/models/http_exception.dart';

const kFileShopUserData = 'shopUserData';

class Auth with ChangeNotifier {
  String _token;
  DateTime _tokenExpiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth => token != null;

  String get token {
    if (_tokenExpiryDate != null &&
        _tokenExpiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId => _userId;

  Future<void> signup(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(kFileShopUserData)) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString(kFileShopUserData)) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _tokenExpiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _tokenExpiryDate = null;
    _cancelTimer();

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(kFileShopUserData);
  }

  void _autoLogout() {
    _cancelTimer();
    final timeToExpire = _tokenExpiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpire), logout);
  }

  void _cancelTimer() {
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
  }

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    const String apiKey = 'AIzaSyBw6S6RzmHMuNDmzmjUg02G4KfYg3MkatA';
    final String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$apiKey';
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
      _tokenExpiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _tokenExpiryDate.toIso8601String(),
      });
      prefs.setString(kFileShopUserData, userData);
    } catch (onError) {
      throw onError;
    }
  }

  String errorMessage(dynamic error) {
    var errorMsg = 'Authentication failed';
    if (error.toString().contains('EMAIL_EXIST')) {
      errorMsg = 'This Email is already in use.';
    } else if (error.toString().contains('INVALID_EMAIL')) {
      errorMsg = 'This is not a valid Email address';
    } else if (error.toString().contains('WEAK_PASSWORD')) {
      errorMsg = 'The password is too weak';
    } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
      errorMsg = 'Could not find a User with that Email.';
    } else if (error.toString().contains('INVALID_PASSWORD')) {
      errorMsg = 'Invalid password.';
    }

    return errorMsg;
  }

  String get genErrorMessage {
    return 'Could not authenticate, Pls. try again later';
  }
}
