import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../models/user_model.dart';
import '../services/mongo_service.dart';

class AuthRepository {
  AuthRepository({MongoService? mongo}) : _mongo = mongo ?? MongoService();

  final MongoService _mongo;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final users = await _mongo.collection('users');
    final existingUser = await users.findOne(where.eq('email', normalizedEmail));

    if (existingUser != null) {
      throw AuthException('Email sudah terdaftar.');
    }

    final salt = _createSalt();
    final now = DateTime.now().toUtc();
    final user = {
      '_id': ObjectId().oid,
      'name': name.trim(),
      'email': normalizedEmail,
      'passwordSalt': salt,
      'passwordHash': _hashPassword(password, salt),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    await users.insertOne(user);
    return UserModel.fromJson(user);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final users = await _mongo.collection('users');
    final user = await users.findOne(where.eq('email', normalizedEmail));

    if (user == null) {
      throw AuthException('Email atau kata sandi salah.');
    }

    final salt = user['passwordSalt']?.toString();
    final passwordHash = user['passwordHash']?.toString();
    if (salt == null || passwordHash == null) {
      throw AuthException('Data akun tidak valid.');
    }

    if (_hashPassword(password, salt) != passwordHash) {
      throw AuthException('Email atau kata sandi salah.');
    }

    return UserModel.fromJson(user);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final hmac = Hmac(sha256, utf8.encode(salt));
    return hmac.convert(utf8.encode(password)).toString();
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
