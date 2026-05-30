import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/detection_item.dart';
import '../history/history_controller.dart';
import 'result_controller.dart';

/// Durasi animasi loading sebelum konten hasil ditampilkan
const _kAnalysisDuration = Duration(milliseconds: 2200);

class ResultView extends StatefulWidget {
  final List<DetectionItem> detections;
  const ResultView({super.key, required this.detections});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView>
    with SingleTickerProviderStateMixin {
  late final ResultController _controller;
  final Set<int> _expandedIndices = {0};
  bool _isSaving = false;
  bool _savedDone = false;
  bool _isAnalyzing = true;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  final Color primaryBrown = const Color(0xFF6D4C41);
  final Color accentBrown = const Color(0xFF4E342E);
  final Color bgColor = const Color(0xFFD7D3C1);

  @override
  void initState() {
    super.initState();
    _controller = ResultController(widget.detections);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    Future.delayed(_kAnalysisDuration, () {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        _fadeCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
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
      body: _isAnalyzing ? _buildAnalyzingScreen() : _buildResultContent(),
    );
  }

  // ─── Loading Screen ────────────────────────────────────────────────────────
  Widget _buildAnalyzingScreen() {
    return _AnalyzingScreen(bgColor: bgColor, accentBrown: accentBrown);
  }

  // ─── Result Content ────────────────────────────────────────────────────────
  Widget _buildResultContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 15),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: accentBrown,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: _controller.reports.length > 1
                          ? 'Top ${_controller.reports.length} Kemungkinan Diagnosa'
                          : 'Hasil Diagnosa',
                    ),
                    if (_controller.reports.length > 1)
                      TextSpan(
                        text: '  (diurutkan dari yang paling mungkin)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                          color: accentBrown.withValues(alpha: 0.65),
                        ),
                      ),
                  ],
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

  // ─── Disease Report Card ───────────────────────────────────────────────────
  Widget _buildDiseaseReportCard(DiseaseReport report, int index) {
    final isExpanded = _expandedIndices.contains(index);
    final total = _controller.reports.length;

    // Label "Diagnosa N" — hanya tampil jika ada lebih dari 1 hasil
    final diagnosisLabel = total > 1 ? 'Diagnosa ${index + 1}' : null;

    final cardBorder = index == 0 && total > 1
        ? Border.all(color: primaryBrown, width: 2)
        : Border.all(color: Colors.transparent, width: 0);

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

    final isHealthy = report.status.toLowerCase().contains('sehat') ||
        report.status.toLowerCase().contains('bebas');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: index == 0 ? 0.07 : 0.04),
            blurRadius: index == 0 ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label "Diagnosa N" di atas kartu
          if (diagnosisLabel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: index == 0
                    ? primaryBrown.withValues(alpha: 0.92)
                    : accentBrown.withValues(alpha: 0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Text(
                diagnosisLabel,
                style: TextStyle(
                  color: index == 0 ? Colors.white : accentBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),

          // Isi kartu
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHealthy
                            ? const Color(0xFFE8F5E9)
                            : report.label == 'None'
                                ? Colors.grey.shade100
                                : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isHealthy
                            ? Icons.check_circle_outline
                            : report.label == 'None'
                                ? Icons.info_outline
                                : Icons.warning_amber_rounded,
                        color: isHealthy
                            ? Colors.green.shade700
                            : report.label == 'None'
                                ? Colors.blueGrey
                                : const Color(0xFFE65100),
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Nama & status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.diseaseName,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: accentBrown,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.scientificName,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: accentBrown.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              report.status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stat chips
                Row(
                  children: [
                    _buildSmallStatCard(
                      'Akurasi AI',
                      report.accuracy > 0 ? '${report.accuracy}%' : '-',
                      Colors.green.shade700,
                    ),
                    const SizedBox(width: 12),
                    _buildSmallStatCard(
                      'Keparahan',
                      report.severity,
                      severityColor,
                    ),
                  ],
                ),
                const Divider(height: 28, thickness: 0.8),

                // Analisis
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: Colors.black87, height: 1.5, fontSize: 13.5),
                    children: [
                      const TextSpan(
                        text: 'Analisis: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: report.analysisDescription),
                    ],
                  ),
                ),

                // Rekomendasi (collapsible)
                if (report.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 14),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rekomendasi Penanganan',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: accentBrown,
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F6EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            report.recommendations.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: accentBrown,
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: accentBrown,
                                      fontSize: 12.5,
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
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Small Stat Card ───────────────────────────────────────────────────────
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

  // ─── Save Button ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: (_isSaving || _savedDone)
            ? null
            : () async {
                setState(() => _isSaving = true);
                final success = await _controller.saveToHistory();
                if (!mounted) return;
                if (Get.isRegistered<HistoryController>()) {
                  Get.find<HistoryController>().refreshHistory();
                }
                setState(() {
                  _isSaving = false;
                  if (success) _savedDone = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Berhasil disimpan ke riwayat!'
                          : 'Tidak ada data untuk disimpan.',
                    ),
                    backgroundColor:
                        success ? const Color(0xFF4E342E) : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Icon(
                _savedDone
                    ? Icons.check_circle_outline
                    : Icons.inventory_2_outlined,
                color: Colors.white,
              ),
        label: Text(
          _savedDone ? 'Tersimpan' : 'Simpan ke Riwayat',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _savedDone
              ? const Color(0xFF4A7C3F)
              : accentBrown,
          disabledBackgroundColor: _savedDone
              ? const Color(0xFF4A7C3F)
              : accentBrown.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

// ─── Analyzing Loading Screen ─────────────────────────────────────────────────
class _AnalyzingScreen extends StatefulWidget {
  final Color bgColor;
  final Color accentBrown;
  const _AnalyzingScreen({required this.bgColor, required this.accentBrown});

  @override
  State<_AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<_AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  static const _steps = [
    'Membaca struktur daun...',
    'Mendeteksi pola penyakit...',
    'Mencocokkan database penyakit...',
    'Menyiapkan laporan diagnosa...',
  ];
  int _stepIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    // Ganti teks langkah setiap ~520ms
    Future.forEach(
      List.generate(_steps.length - 1, (i) => i),
      (i) => Future.delayed(Duration(milliseconds: 520 * (i + 1)), () {
        if (mounted) setState(() => _stepIndex = i + 1);
      }),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.bgColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon pulsing
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentBrown.withValues(alpha: 0.1),
                    border: Border.all(
                      color: widget.accentBrown.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.biotech_rounded,
                    size: 54,
                    color: widget.accentBrown,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Menganalisis Daun',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: widget.accentBrown,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Progress bar indeterminate
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: widget.accentBrown.withValues(alpha: 0.15),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(widget.accentBrown),
                ),
              ),
              const SizedBox(height: 18),
              // Step label dengan AnimatedSwitcher
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Row(
                  key: ValueKey(_stepIndex),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 7,
                      color: widget.accentBrown.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _steps[_stepIndex],
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.accentBrown.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Dot row indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _stepIndex ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == _stepIndex
                          ? widget.accentBrown
                          : widget.accentBrown.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
