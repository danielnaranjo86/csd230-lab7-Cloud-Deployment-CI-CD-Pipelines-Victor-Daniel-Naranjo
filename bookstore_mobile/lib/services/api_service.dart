import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/rest';
    } else {
      return 'http://10.0.2.2:8080/api/rest';
    }
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> login(String username, String password) {
    return http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': username,
        'password': password,
      }),
    );
  }

  Future<http.Response> getBooks(String token) {
    return http.get(Uri.parse('$baseUrl/books'), headers: _headers(token: token));
  }

  Future<http.Response> getMagazines(String token) {
    return http.get(Uri.parse('$baseUrl/magazines'), headers: _headers(token: token));
  }

  Future<http.Response> getGuitars(String token) {
    return http.get(Uri.parse('$baseUrl/guitars'), headers: _headers(token: token));
  }

  Future<http.Response> getDrumKits(String token) {
    return http.get(Uri.parse('$baseUrl/drums'), headers: _headers(token: token));
  }

  Future<http.Response> getCart(String token) {
    return http.get(Uri.parse('$baseUrl/cart'), headers: _headers(token: token));
  }

  Future<http.Response> addToCart(String token, int productId) {
    return http.post(
      Uri.parse('$baseUrl/cart/add/$productId'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> removeFromCart(String token, int productId) {
    return http.delete(
      Uri.parse('$baseUrl/cart/remove/$productId'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> addBook(String token, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl/books'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updateBook(String token, int id, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteBook(String token, int id) {
    return http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> addMagazine(String token, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl/magazines'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updateMagazine(String token, int id, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl/magazines/$id'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteMagazine(String token, int id) {
    return http.delete(
      Uri.parse('$baseUrl/magazines/$id'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> addGuitar(String token, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl/guitars'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updateGuitar(String token, int id, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl/guitars/$id'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteGuitar(String token, int id) {
    return http.delete(
      Uri.parse('$baseUrl/guitars/$id'),
      headers: _headers(token: token),
    );
  }

  Future<http.Response> addDrumKit(String token, Map<String, dynamic> body) {
    return http.post(
      Uri.parse('$baseUrl/drums'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updateDrumKit(String token, int id, Map<String, dynamic> body) {
    return http.put(
      Uri.parse('$baseUrl/drums/$id'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> deleteDrumKit(String token, int id) {
    return http.delete(
      Uri.parse('$baseUrl/drums/$id'),
      headers: _headers(token: token),
    );
  }
}