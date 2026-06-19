import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:leafy_app/core/routes/app_routes.dart';
import 'package:leafy_app/data/models/user_model.dart';
import 'package:leafy_app/data/services/session_service.dart';
import 'package:leafy_app/data/services/mongo_service.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';
import 'package:leafy_app/data/models/detection_result.dart';
import 'package:leafy_app/data/models/scan_history_record.dart';

class HomeController {
  final SessionService _sessionService = SessionService();
  final MongoService _mongo = MongoService();
  final ConnectivityService _connectivity = ConnectivityService();

  final ValueNotifier<int> healthyCount = ValueNotifier<int>(0);
  final ValueNotifier<int> sickCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> statsLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String> syncStatus = ValueNotifier<String>(
    'Memuat data...',
  );

  UserModel? get currentUser => _sessionService.currentUser;

  String get displayName {
    final name = currentUser?.name.trim();
    if (name == null || name.isEmpty) return 'Tim Leafy';
    return name;
  }

  String get avatarInitial {
    final name = displayName.trim();
    if (name.isEmpty) return 'L';
    return name.substring(0, 1).toUpperCase();
  }

  void onScanPressed(BuildContext context) {
    context.push(AppRoutes.scanner);
  }

  Future<void> logout(BuildContext context) async {
    await _sessionService.logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> loadStats() async {
    if (_connectivity.isOffline) {
      syncStatus.value = 'Offline — data lokal';
      _loadStatsFromHive();
      return;
    }

    statsLoading.value = true;
    syncStatus.value = 'Menyinkronkan...';

    try {
      final stats = await _mongo.getDetectionStats(userId: currentUser?.id);

      if (stats.healthy == -1) {
        _loadStatsFromHive();
        syncStatus.value = 'Data lokal (gagal sinkron)';
      } else {
        healthyCount.value = stats.healthy;
        sickCount.value = stats.sick;
        syncStatus.value = 'Semua data aman';
      }
    } catch (_) {
      _loadStatsFromHive();
      syncStatus.value = 'Data lokal (offline)';
    } finally {
      statsLoading.value = false;
    }
  }

  void _loadStatsFromHive() {
    try {
      int h = 0;
      int s = 0;
      final Set<String> processedIds = {};

      if (Hive.isBoxOpen('scan_history')) {
        final box = Hive.box<ScanHistoryRecord>('scan_history');
        for (final item in box.values) {
          processedIds.add(item.id);
          if (item.isHealthy) {
            h++;
          } else {
            s++;
          }
        }
      }

      if (Hive.isBoxOpen('detections')) {
        final box = Hive.box<DetectionResult>('detections');
        for (final item in box.values) {
          if (!processedIds.contains(item.id)) {
            processedIds.add(item.id);
            final label = item.label.toLowerCase();
            if (label.contains('healthy')) {
              h++;
            } else {
              s++;
            }
          }
        }
      }

      healthyCount.value = h;
      sickCount.value = s;
    } catch (_) {
      healthyCount.value = 0;
      sickCount.value = 0;
    }
  }

  void dispose() {
    healthyCount.dispose();
    sickCount.dispose();
    statsLoading.dispose();
    syncStatus.dispose();
  }
}
