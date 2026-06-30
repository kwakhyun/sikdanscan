import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import 'json_helpers.dart';

class StoredUser {
  const StoredUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    this.displayName = '',
  });

  final String id;
  final String email;
  final String displayName;
  final String passwordHash;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'passwordHash': passwordHash,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  Map<String, dynamic> toPublicJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static StoredUser? fromJson(Object? value) {
    final map = asStringMap(value);
    if (map == null) return null;

    final id = readString(map['id']);
    final email = readString(map['email']);
    final passwordHash = readString(map['passwordHash']);
    final createdAtValue = readString(map['createdAt']);
    final createdAt = createdAtValue == null
        ? null
        : DateTime.tryParse(createdAtValue);

    if (id == null ||
        email == null ||
        passwordHash == null ||
        createdAt == null) {
      return null;
    }

    return StoredUser(
      id: id,
      email: normalizeEmail(email),
      displayName: readString(map['displayName']) ?? '',
      passwordHash: passwordHash,
      createdAt: createdAt,
    );
  }
}

abstract interface class ServerDatabase {
  Future<void> open();
  bool get isReady;
  String get description;

  Future<StoredUser?> findUserByEmail(String email);
  Future<StoredUser?> findUserById(String id);
  Future<StoredUser> createUser({
    required String email,
    required String passwordHash,
    String displayName,
  });

  Future<Map<String, dynamic>> addMealRecord(
    String userId,
    Map<String, dynamic> record,
  );
  Future<List<Map<String, dynamic>>> listMealRecords(String userId);

  void close();
}

class FileServerDatabase implements ServerDatabase {
  FileServerDatabase(String path) : _file = File(path);

  final File _file;
  final _uuid = const Uuid();
  final Map<String, StoredUser> _usersById = {};
  final List<Map<String, dynamic>> _mealRecords = [];

  Future<void>? _openFuture;
  Future<void> _writeChain = Future.value();
  bool _isReady = false;

  @override
  bool get isReady => _isReady;

  @override
  String get description => _file.path;

  @override
  Future<void> open() {
    return _openFuture ??= _open();
  }

  Future<void> _open() async {
    final parent = _file.parent;
    if (!await parent.exists()) {
      await parent.create(recursive: true);
    }

    if (!await _file.exists()) {
      await _flush();
      _isReady = true;
      return;
    }

    final content = await _file.readAsString();
    if (content.trim().isEmpty) {
      _isReady = true;
      return;
    }

    final decoded = jsonDecode(content);
    final root = asStringMap(decoded) ?? const <String, dynamic>{};

    final users = root['users'];
    if (users is List) {
      for (final userJson in users) {
        final user = StoredUser.fromJson(userJson);
        if (user != null) _usersById[user.id] = user;
      }
    }

    final mealRecords = root['mealRecords'];
    if (mealRecords is List) {
      for (final record in mealRecords) {
        final map = asStringMap(record);
        if (map != null) _mealRecords.add(Map<String, dynamic>.from(map));
      }
    }

    _isReady = true;
  }

  @override
  Future<StoredUser?> findUserByEmail(String email) async {
    await open();
    final normalized = normalizeEmail(email);
    for (final user in _usersById.values) {
      if (user.email == normalized) return user;
    }
    return null;
  }

  @override
  Future<StoredUser?> findUserById(String id) async {
    await open();
    return _usersById[id];
  }

  @override
  Future<StoredUser> createUser({
    required String email,
    required String passwordHash,
    String displayName = '',
  }) {
    return _exclusive(() async {
      await open();
      final normalized = normalizeEmail(email);
      if (await findUserByEmail(normalized) != null) {
        throw const DuplicateUserException();
      }

      final user = StoredUser(
        id: _uuid.v4(),
        email: normalized,
        displayName: displayName.trim(),
        passwordHash: passwordHash,
        createdAt: DateTime.now().toUtc(),
      );
      _usersById[user.id] = user;
      await _flush();
      return user;
    });
  }

  @override
  Future<Map<String, dynamic>> addMealRecord(
    String userId,
    Map<String, dynamic> record,
  ) {
    return _exclusive(() async {
      await open();
      final stored = {
        'id': _uuid.v4(),
        'userId': userId,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'record': record,
      };
      _mealRecords.add(stored);
      await _flush();
      return Map<String, dynamic>.from(stored);
    });
  }

  @override
  Future<List<Map<String, dynamic>>> listMealRecords(String userId) async {
    await open();
    return _mealRecords
        .where((record) => record['userId'] == userId)
        .map((record) => Map<String, dynamic>.from(record))
        .toList(growable: false);
  }

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final next = _writeChain.then((_) => action());
    _writeChain = next.then<void>((_) {}, onError: (_, _) {});
    return next;
  }

  Future<void> _flush() async {
    final payload = {
      'version': 1,
      'users': _usersById.values.map((user) => user.toJson()).toList(),
      'mealRecords': _mealRecords,
    };
    final temp = File('${_file.path}.tmp');
    await temp.writeAsString(jsonEncode(payload), flush: true);
    if (await _file.exists()) {
      await _file.delete();
    }
    await temp.rename(_file.path);
  }

  @override
  void close() {}
}

class DuplicateUserException implements Exception {
  const DuplicateUserException();
}

String normalizeEmail(String email) => email.trim().toLowerCase();
