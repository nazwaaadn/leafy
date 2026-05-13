import 'package:hive_flutter/hive_flutter.dart';
import 'package:leafy_app/data/models/user_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _boxName = 'session';
  static const String _userIdKey = 'userId';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _createdAtKey = 'createdAt';

  late Box<dynamic> _box;

  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  bool get isLoggedIn => _box.get(_userIdKey) != null;

  UserModel? get currentUser {
    final userId = _box.get(_userIdKey)?.toString();
    if (userId == null || userId.isEmpty) return null;

    return UserModel(
      id: userId,
      name: _box.get(_nameKey)?.toString() ?? '',
      email: _box.get(_emailKey)?.toString() ?? '',
      createdAt: DateTime.tryParse(_box.get(_createdAtKey)?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> saveUser(UserModel user) async {
    await _box.putAll({
      _userIdKey: user.id,
      _nameKey: user.name,
      _emailKey: user.email,
      _createdAtKey: user.createdAt.toIso8601String(),
    });
  }

  Future<void> logout() async {
    await _box.deleteAll([
      _userIdKey,
      _nameKey,
      _emailKey,
      _createdAtKey,
    ]);
  }
}
