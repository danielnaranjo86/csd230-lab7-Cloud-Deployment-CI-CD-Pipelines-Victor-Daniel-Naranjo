import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  String? _token;
  List<String> _roles = [];
  bool _isInitialized = false;

  String? get token => _token;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isAdmin => _roles.contains('ROLE_ADMIN');
  bool get isInitialized => _isInitialized;

  Future<void> loadToken() async {
    _token = await _storageService.getToken();
    _roles = _decodeRoles(_token);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    _token = token;
    _roles = _decodeRoles(token);
    await _storageService.saveToken(token);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _roles = [];
    await _storageService.clearToken();
    notifyListeners();
  }

  List<String> _decodeRoles(String? token) {
    if (token == null || token.isEmpty) return [];

    try {
      final parts = token.split('.');
      if (parts.length != 3) return [];

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final map = jsonDecode(payload);

      final roles = map['roles'];

      if (roles is List) {
        return roles.map((e) => e.toString()).toList();
      }

      if (roles is String) {
        return [roles];
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}