import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../history_controller.dart';
import 'detail_history_controller.dart';

class HistoryDetailView extends StatelessWidget {
  final ScanRecord record;

  const HistoryDetailView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryDetailController());

    return Scaffold(
      backgroundColor: const Color(0xFFC7C2B4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4A3728)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Detail Pemindaian',
          style: TextStyle(color: Color(0xFF4A3728), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildAnalysisCard(controller),
              const SizedBox(height: 16),
              _buildRecommendationCard(context, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(HistoryDetailController controller) {
    final bool isHealthy = record.healthStatus == HealthStatus.healthy;
    final Color statusColor = isHealthy ? const Color(0xFF4A7C3F) : const Color(0xFF8B5A33);
    final IconData iconData = isHealthy ? Icons.eco_rounded : Icons.warning_amber_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(color: isHealthy ? const Color(0xFFE8F5E9) : const Color(0xFFF6E8B6), borderRadius: BorderRadius.circular(16)),
                child: Icon(iconData, color: statusColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.conditionName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF4A3728))),
                    Text('Log ID: ${record.logId}', style: const TextStyle(fontSize: 14, color: Colors.black45)),
                    Text('Status: ${isHealthy ? 'Sehat' : 'Terinfeksi'}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatBox('Akurasi AI', '${record.accuracyPercent}%', const Color(0xFF3A7D1E))),
              const SizedBox(width: 12),
              Expanded(child: _buildStatBox('Keparahan', controller.getSeverity(record), statusColor)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.black54),
              children: [
                const TextSpan(text: 'Analisis: ', style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: controller.getAnalysisText(record)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, HistoryDetailController controller) {
    final recommendations = controller.getRecommendations(record);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF4EFE6), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4A3728)),
              SizedBox(width: 10),
              Text('Rekomendasi Penanganan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF4A3728))),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(recommendations.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 14, backgroundColor: const Color(0xFF6B3A2A), child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 13))),
                  const SizedBox(width: 14),
                  Expanded(child: Text(recommendations[index], style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600, color: Color(0xFF8B5A33)))),
                ],
              ),
            );
          }),
          
        ],
      ),
    );
  }
}