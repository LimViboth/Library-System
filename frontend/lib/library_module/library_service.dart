import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const base = "http://10.0.2.2:8000/api";

class LibraryService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Token management
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<int> testToken(String token) async {
    final String url = "$base/user";
    try {
      http.Response response = await http.get(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        Uri.parse(url),
      );
      return response.statusCode;
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final String url = "$base/login";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(response.body);
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final String url = "$base/register";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(response.body);
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        return data;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Logout user
  static Future<String> logout(String token) async {
    final String url = "$base/logout";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(response.body);
        await deleteToken();
        return response.body;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final String url = "$base/profile";
    try {
      http.Response response = await http.get(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Get all books
  static Future<Map<String, dynamic>> getBooks() async {
    final String url = "$base/books";
    try {
      http.Response response = await http.get(
        headers: {
          "Accept": "application/json",
        },
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Get a specific book
  static Future<Map<String, dynamic>> getBook(int bookId, String token) async {
    final String url = "$base/books/$bookId";
    try {
      http.Response response = await http.get(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Create a new book (admin only)
  static Future<bool> createBook(Map<String, dynamic> bookData, String token) async {
    final String url = "$base/books";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bookData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Update a book (admin only)
  static Future<bool> updateBook(int bookId, Map<String, dynamic> bookData, String token) async {
    final String url = "$base/books/$bookId";
    try {
      http.Response response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(bookData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Delete a book (admin only)
  static Future<bool> deleteBook(int bookId, String token) async {
    final String url = "$base/books/$bookId";
    try {
      http.Response response = await http.delete(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Borrow a book
  static Future<bool> borrowBook(int bookId, String token) async {
    final String url = "$base/books/$bookId/borrow";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Return a book
  static Future<bool> returnBook(int bookId, String token) async {
    final String url = "$base/books/$bookId/return";
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }

  /// Get user's borrowed books
  static Future<Map<String, dynamic>> getMyBooks(String token) async {
    final String url = "$base/my-books";
    try {
      http.Response response = await http.get(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Error status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Network error: ${e.toString()}");
    }
  }
}
