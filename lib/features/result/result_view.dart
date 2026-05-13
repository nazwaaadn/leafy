import 'package:flutter/material.dart';
import '../../data/models/detection_item.dart';
import 'result_controller.dart';

class ResultView extends StatefulWidget {
  final List<DetectionItem> detections;
  const ResultView({super.key, required this.detections});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final ResultController _controller = ResultController();
  final Color primaryBrown = const Color(0xFF6D4C41);
  final Color accentBrown = const Color(0xFF4E342E);
  final Color bgColor = const Color(0xFFD7D3C1);

  @override
  Widget build(BuildContext context) {
    print(
      "DEBUG: ResultView build called with ${widget.detections.length} detections",
    );
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildMainAnalysisCard(),
            const SizedBox(height: 20),
            _buildRecommendationCard(),
            const SizedBox(height: 25),
            _buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF8D6E63),
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.diseaseName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: accentBrown,
                    ),
                  ),
                  Text(
                    _controller.scientificName,
                    style: TextStyle(fontSize: 18, color: accentBrown),
                  ),
                  Text(
                    "Status: ${_controller.status}",
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSmallStatCard(
                "Akurasi AI",
                "${_controller.accuracy}%",
                Colors.green.shade700,
              ),
              const SizedBox(width: 12),
              _buildSmallStatCard(
                "Keparahan",
                _controller.severity,
                accentBrown,
              ),
            ],
          ),
          const Divider(height: 40, thickness: 0.8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, height: 1.5),
              children: [
                const TextSpan(
                  text: "Analisis: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: _controller.analysisDescription),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black26),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: accentBrown),
              const SizedBox(width: 10),
              Text(
                "Rekomendasi Penanganan",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: accentBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._controller.recommendations.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: accentBrown,
                    child: Text(
                      "${entry.key + 1}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: accentBrown,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _controller.saveToHistory,
        icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
        label: const Text(
          "Simpan ke Riwayat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
