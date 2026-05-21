import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HistoryDetailController extends GetxController {
  final RxBool isLoading = false.obs;

  final String title = 'Bercak Daun';
  final String subtitle = '(Leaf Spot)';
  final String status = 'Terinfeksi';
  final String accuracy = '85.4%';
  final String severity = 'Sedang';
  
  final String analysisText = 
      'Ditemukan bercak berwarna kuning kecoklatan pada area tengah daun, diakibatkan oleh patogen jamur "Cercospora". Kondisi cuaca lembab mempercepat penyebaran.';
  
  final List<String> recommendations = [
    'Isolasi atau pangkas daun yang terinfeksi parah agar jamur tidak menyebar',
    'Aplikasikan fungisida berbahan aktif tembaga atau mankozeb (?) pada pagi hari',
    'Kurangi intensitas penyiraman pada area daun, siram langsung ke area perakaran'
  ];

  void saveToHistory() {
    Get.snackbar(
      'Berhasil',
      'Data pemindaian berhasil disimpan ke riwayat.',
      backgroundColor: const Color(0xFF4A7C3F),
      colorText: Get.theme.colorScheme.onPrimary,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}