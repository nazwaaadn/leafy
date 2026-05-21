import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../history_controller.dart';

class HistoryDetailController extends GetxController {
  final RxBool isLoading = false.obs;

  String getSeverity(ScanRecord record) {
    if (record.healthStatus == HealthStatus.healthy) return 'Aman';
    if (record.accuracyPercent > 90) return 'Tinggi';
    if (record.accuracyPercent > 80) return 'Sedang';
    return 'Rendah';
  }

  String getAnalysisText(ScanRecord record) {
    if (record.healthStatus == HealthStatus.healthy) {
      return 'Tanaman dalam kondisi prima. Tidak terdeteksi adanya patogen atau tanda-tanda penyakit pada area daun yang dipindai.';
    }
    return 'Ditemukan indikasi infeksi "${record.conditionName}". Gejala umum dapat berupa perubahan warna atau bercak pada daun. Faktor lingkungan sangat mempengaruhi penyebaran.';
  }

  List<String> getRecommendations(ScanRecord record) {
    if (record.healthStatus == HealthStatus.healthy) {
      return [
        'Lanjutkan rutinitas penyiraman dan pemupukan yang sudah ada',
        'Lakukan pemindaian berkala setiap minggu untuk memastikan kondisi tetap sehat',
      ];
    }
    return [
      'Isolasi atau pangkas daun yang terinfeksi agar penyakit tidak menyebar',
      'Aplikasikan fungisida atau pestisida organik yang sesuai pada pagi hari',
      'Kurangi intensitas penyiraman pada daun, fokuskan pada area perakaran',
    ];
  }

  void saveToHistory(String logId) {
    Get.snackbar(
      'Berhasil',
      'Catatan log $logId diperbarui.',
      backgroundColor: const Color(0xFF4A7C3F),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}