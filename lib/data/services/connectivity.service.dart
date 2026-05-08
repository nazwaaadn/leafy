import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  bool _isOnline = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  Stream<bool> get onStatusChange => _controller.stream;

  Future<void> init() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = _evalResult(result);

    _connectivity.onConnectivityChanged.listen((result) {
      final status = _evalResult(result);
      if (status != _isOnline) {
        _isOnline = status;
        _controller.add(_isOnline);
      }
    });
  }

  bool _evalResult(List<ConnectivityResult> result) {
    return result.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() => _controller.close();
}
