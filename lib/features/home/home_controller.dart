import 'package:flutter/material.dart';

class HomeController {
  // Dummy Data untuk Statistik
  final int healthyCount = 127;
  final int sickCount = 10;
  final String syncStatus = "Semua data aman";

  // Fungsi navigasi atau aksi
  void onScanPressed() {
    print("Membuka Kamera YOLOv8...");
  }
}