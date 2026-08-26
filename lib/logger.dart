import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum LogLevel {
  info(0),
  warn(1),
  error(2),
  critical(3);

  const LogLevel(this.levelNumber);

  final int levelNumber;
}

class Logger {
  static const String defaultBaseUrl = 'https://logger.yabzec.uk';

  final String _subject;
  final String _title;
  final String _clientId;
  final String _clientSecret;
  final Uri _endpoint;
  final http.Client _httpClient;

  Logger(
    this._subject,
    this._title, {
    required String clientId,
    required String clientSecret,
    String baseUrl = defaultBaseUrl,
    http.Client? httpClient,
  })  : _clientId = clientId,
        _clientSecret = clientSecret,
        _endpoint = Uri.parse(baseUrl).resolve('/api/insert'),
        _httpClient = httpClient ?? http.Client();

  /// Releases the underlying [http.Client]. Only call this when the logger owns
  /// the client, that is when no `httpClient` was passed to the constructor.
  void dispose() {
    _httpClient.close();
  }

  Future<void> info(String content, [Object? e, StackTrace? s]) async {
    return _log(LogLevel.info, content, e, s);
  }

  Future<void> warn(String content, [Object? e, StackTrace? s]) async {
    return _log(LogLevel.warn, content, e, s);
  }

  Future<void> error(String content, [Object? e, StackTrace? s]) async {
    return _log(LogLevel.error, content, e, s);
  }

  Future<void> critical(String content, [Object? e, StackTrace? s]) async {
    return _log(LogLevel.critical, content, e, s);
  }

  Future<void> _log(
    LogLevel level,
    String content, [
    Object? e,
    StackTrace? s,
  ]) async {
    log(content);

    if (kDebugMode) {
      return;
    }

    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    late final String device;
    late final String os;

    if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      device = info.modelName;
      os = "${info.systemName} - ${info.systemVersion}";
    } else {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      device = "${info.manufacturer} - ${info.name}";
      os = "ANDROID - ${info.version.release}";
    }

    try {
      final response = await _httpClient.put(
        _endpoint,
        headers: {
          'Content-Type': 'application/json',
          'CF-Access-Client-Id': _clientId,
          'CF-Access-Client-Secret': _clientSecret,
        },
        body: jsonEncode({
          'date': DateTime.now().millisecondsSinceEpoch,
          'device': device,
          'os': os,
          'subject': _subject,
          'level': level.levelNumber,
          'title': _title,
          'content': _buildContent(content, e, s),
        }),
      );

      if (response.statusCode != 200) {
        log('Logger request failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  String _buildContent(String content, Object? e, StackTrace? s) {
    final StringBuffer buffer = StringBuffer(content);

    if (e != null) {
      buffer.write('\n$e');
    }

    if (s != null) {
      buffer.write('\n$s');
    }

    return buffer.toString();
  }
}
