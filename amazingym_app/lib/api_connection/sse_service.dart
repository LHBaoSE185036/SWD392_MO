import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class SSEService {
  final String url;
  final Map<String, String> headers;
  final _controller = BehaviorSubject<String>();
  Stream<String> get stream =>
      _controller.stream.debounceTime(Duration(seconds: 1));

  SSEService._internal(this.url, this.headers);

  static final Map<String, SSEService> _cache = {};

  factory SSEService(String url, Map<String, String> headers) {
    final cacheKey = '$url-${headers['Authorization']}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    } else {
      final service = SSEService._internal(url, headers);
      _cache[cacheKey] = service;
      return service;
    }
  }

  void startListening() async {
    final request = http.Request('GET', Uri.parse(url));
    request.headers.addAll(headers);
    final response = await request.send();

    response.stream
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .listen((data) {
      _controller.add(data);
    });
  }

  void dispose() {
    _controller.close();
  }
}
