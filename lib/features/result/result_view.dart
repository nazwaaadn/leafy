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
  late final ResultController _controller;
  final Set<int> _expandedIndices = {0};
  final Color primaryBrown = const Color(0xFF6D4C41);
  final Color accentBrown = const Color(0xFF4E342E);
  final Color bgColor = const Color(0xFFD7D3C1);

  @override
  void initState() {
    super.initState();
    _controller = ResultController(widget.detections);
  }

  @override
  Widget build(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 15),
              child: Text(
                _controller.reports.length > 1
                    ? "Hasil Diagnosa (${_controller.reports.length} Terdeteksi):"
                    : "Hasil Diagnosa:",
                style: TextStyle(
                  color: accentBrown,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ..._controller.reports.asMap().entries.map((entry) {
              return _buildDiseaseReportCard(entry.value, entry.key);
            }),
            const SizedBox(height: 10),
            _buildSaveButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseReportCard(DiseaseReport report, int index) {
    final isExpanded = _expandedIndices.contains(index);
    final isMain = index == 0;
    
    Color statusColor;
    if (report.status.toLowerCase().contains('aman') || 
        report.status.toLowerCase().contains('sehat') || 
        report.status.toLowerCase().contains('bebas')) {
      statusColor = Colors.green.shade700;
    } else if (report.status.toLowerCase().contains('tidak teridentifikasi')) {
      statusColor = Colors.blueGrey;
    } else {
      statusColor = Colors.deepOrange;
    }

    Color severityColor;
    switch (report.severity.toLowerCase()) {
      case 'tinggi':
      case 'sangat tinggi':
        severityColor = Colors.red.shade700;
        break;
      case 'sedang':
        severityColor = Colors.orange.shade700;
        break;
      case 'rendah':
      case 'tidak ada':
        severityColor = Colors.green.shade700;
        break;
      default:
        severityColor = accentBrown;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: report.isAlternative ? Colors.white.withValues(alpha: 0.85) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: report.isAlternative
            ? Border.all(color: Colors.grey.shade400, width: 1.5)
            : (isMain && _controller.reports.length > 1
                ? Border.all(color: primaryBrown, width: 2)
                : Border.all(color: Colors.white, width: 0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: report.isAlternative ? 0.02 : 0.05),
            blurRadius: report.isAlternative ? 5 : 10,
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
                  color: report.isAlternative
                      ? Colors.grey.shade100
                      : (report.status.toLowerCase().contains('sehat') || 
                              report.status.toLowerCase().contains('bebas')
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF9C4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  report.status.toLowerCase().contains('sehat') || 
                          report.status.toLowerCase().contains('bebas')
                      ? Icons.check_circle_outline
                      : report.label == "None"
                          ? Icons.info_outline
                          : Icons.warning_amber_rounded,
                  color: report.isAlternative
                      ? Colors.grey.shade600
                      : (report.status.toLowerCase().contains('sehat') || 
                              report.status.toLowerCase().contains('bebas')
                          ? Colors.green.shade800
                          : const Color(0xFF8D6E63)),
                  size: 40,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.isAlternative)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "ALTERNATIF DIAGNOSA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else if (isMain && _controller.reports.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: primaryBrown,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "DETEKSI UTAMA",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    Text(
                      report.diseaseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accentBrown,
                      ),
                    ),
                    Text(
                      report.scientificName,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: accentBrown.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status: ${report.status}",
                      style: TextStyle(
                        color: report.isAlternative ? Colors.blueGrey.shade700 : statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSmallStatCard(
                report.isAlternative ? "Tipe" : "Akurasi AI",
                report.isAlternative ? "Pembanding" : "${report.accuracy}%",
                report.isAlternative ? Colors.blueGrey.shade700 : Colors.green.shade700,
              ),
              const SizedBox(width: 12),
              _buildSmallStatCard(
                "Keparahan",
                report.severity,
                report.isAlternative ? Colors.blueGrey.shade700 : severityColor,
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
              children: [
                const TextSpan(
                  text: "Analisis: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: report.analysisDescription),
              ],
            ),
          ),
          if (report.recommendations.isNotEmpty) ...[
            const SizedBox(height: 15),
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedIndices.remove(index);
                  } else {
                    _expandedIndices.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rekomendasi Penanganan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentBrown,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: accentBrown,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6EE),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: report.recommendations.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: accentBrown,
                            child: Text(
                              "${entry.key + 1}",
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                color: accentBrown,
                                fontSize: 13,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
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
                fontSize: value.length > 7 ? 14 : 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
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
