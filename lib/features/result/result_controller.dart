import 'package:uuid/uuid.dart';
import '../../data/models/detection_item.dart';
import '../../data/models/scan_history_record.dart';
import '../../data/services/history_service.dart';
import '../../data/services/sync_service.dart';

class DiseaseReport {
  final String label;
  final String diseaseName;
  final String scientificName;
  final String status;
  final double accuracy;
  final String severity;
  final String analysisDescription;
  final List<String> recommendations;

  DiseaseReport({
    required this.label,
    required this.diseaseName,
    required this.scientificName,
    required this.status,
    required this.accuracy,
    required this.severity,
    required this.analysisDescription,
    required this.recommendations,
  });
}

class ResultController {
  List<DiseaseReport> reports = [];

  String get diseaseName =>
      reports.isNotEmpty ? reports[0].diseaseName : "Tidak Diketahui";
  String get scientificName =>
      reports.isNotEmpty ? reports[0].scientificName : "";
  String get status => reports.isNotEmpty ? reports[0].status : "Aman";
  double get accuracy => reports.isNotEmpty ? reports[0].accuracy : 0.0;
  String get severity => reports.isNotEmpty ? reports[0].severity : "Rendah";
  String get analysisDescription => reports.isNotEmpty
      ? reports[0].analysisDescription
      : "Tidak ada informasi analisis yang tersedia.";
  List<String> get recommendations =>
      reports.isNotEmpty ? reports[0].recommendations : [];

  ResultController(List<DetectionItem> detections) {
    if (detections.isNotEmpty) {
      final Map<String, double> labelMaxConfidence = {};
      for (var d in detections) {
        final currentMax = labelMaxConfidence[d.label] ?? 0.0;
        if (d.confidence > currentMax) {
          labelMaxConfidence[d.label] = d.confidence;
        }
      }

      for (var entry in labelMaxConfidence.entries) {
        final label = entry.key;
        final confidence = entry.value;
        final accuracyPercent = double.parse(
          (confidence * 100).toStringAsFixed(1),
        );
        reports.add(_createReportForLabel(label, accuracyPercent));
      }

      reports.sort((a, b) => b.accuracy.compareTo(a.accuracy));
      if (reports.length > 3) {
        reports = reports.sublist(0, 3);
      }
    } else {
      reports.add(
        DiseaseReport(
          label: "None",
          diseaseName: "Tidak Terdeteksi",
          scientificName: "No Detections",
          status: "Tidak Teridentifikasi",
          accuracy: 0.0,
          severity: "-",
          analysisDescription:
              "Model tidak dapat mendeteksi adanya pola penyakit atau daun pada gambar. Pastikan gambar cukup terang, fokus, dan objek daun terlihat dengan jelas.",
          recommendations: [
            "Pastikan daun berada di tengah frame kamera",
            "Coba ambil gambar dengan pencahayaan yang lebih terang",
            "Dekatkan kamera ke objek daun (hindari latar belakang yang terlalu ramai)",
          ],
        ),
      );
    }
  }

  DiseaseReport _createReportForLabel(String rawLabel, double accuracyPercent) {
    final label = rawLabel.toLowerCase();
    String diseaseName = "Tidak Diketahui";
    String scientificName = "($rawLabel)";
    String status = "Terdeteksi";
    String severity = "Perlu Pemeriksaan";
    String analysisDescription =
        "Model mendeteksi kondisi '$rawLabel' pada daun tanaman. Kondisi ini memerlukan perhatian untuk memastikan tidak mengganggu kesehatan tanaman secara keseluruhan.";
    List<String> recommendations = [
      "Pantau perkembangan gejala ini pada daun lainnya",
      "Lakukan sanitasi kebun dengan membersihkan daun kering dan gulma",
      "Gunakan aplikasi pengendali hama jika terdapat tanda-tanda kerusakan fisik oleh serangga",
    ];

    if (label.contains('spot')) {
      diseaseName = "Bercak Daun";
      status = "Terinfeksi";
      severity = "Sedang";
      analysisDescription =
          "Ditemukan bercak pada area daun yang terdeteksi sebagai '$rawLabel', umumnya diakibatkan oleh patogen jamur atau bakteri. Kondisi cuaca lembab dapat mempercepat penyebaran.";
      recommendations = [
        "Pangkas dan musnahkan daun yang terinfeksi parah agar jamur tidak menyebar",
        "Aplikasikan fungisida berbahan aktif tembaga atau mankozeb pada pagi hari jika infeksi meluas",
        "Kurangi intensitas penyiraman pada area daun, siram langsung ke area perakaran",
      ];
    } else if (label.contains('blight')) {
      diseaseName = "Hawar Daun";
      status = "Terinfeksi";
      severity = "Tinggi";
      analysisDescription =
          "Daun menunjukkan gejala hawar (blight) dengan area mati berwarna coklat atau kehitaman yang luas. Penyakit '$rawLabel' ini menyebar dengan cepat dan dapat merusak seluruh tanaman jika tidak segera ditangani.";
      recommendations = [
        "Segera potong dan buang bagian tanaman yang terinfeksi jauh dari lokasi tanam",
        "Gunakan fungisida sistemik yang sesuai untuk menghentikan penyebaran",
        "Pastikan sirkulasi udara yang baik di sekitar tanaman dengan menjaga jarak tanam",
      ];
    } else if (label.contains('mildew')) {
      diseaseName = "Embun Tepung";
      status = "Terinfeksi";
      severity = "Sedang";
      analysisDescription =
          "Terdapat lapisan serbuk putih seperti tepung pada permukaan daun. Penyakit embun tepung ($rawLabel) ini menghambat fotosintesis dan membuat daun mengering.";
      recommendations = [
        "Semprotkan fungisida berbasis sulfur atau kalium bikarbonat sesuai dosis",
        "Hindari kelembaban yang terlalu tinggi terutama di malam hari",
        "Hindari menyiram daun dari atas (lakukan penyiraman di pangkal batang)",
      ];
    } else if (label.contains('rust')) {
      diseaseName = "Karat Daun";
      status = "Terinfeksi";
      severity = "Tinggi";
      analysisDescription =
          "Terdapat bintik-bintik berwarna oranye atau karat kemerahan pada bagian bawah atau atas daun. Penyakit karat daun ($rawLabel) sangat menular melalui spora yang terbawa angin.";
      recommendations = [
        "Segera pangkas dan singkirkan semua daun yang terinfeksi karat",
        "Gunakan fungisida tembaga atau fungisida sistemik secara rutin",
        "Sterilkan alat berkebun setelah memangkas tanaman yang terinfeksi agar tidak menular ke tanaman sehat",
      ];
    } else if (label.contains('mosaic') || label.contains('virus')) {
      diseaseName = "Virus Mosaik / Keriting";
      status = "Terinfeksi";
      severity = "Sangat Tinggi";
      analysisDescription =
          "Daun mengalami perubahan warna belang-belang kuning hijau (mosaik), mengerut, dan pertumbuhan terhambat akibat infeksi virus ($rawLabel). Penyakit ini umumnya ditularkan oleh hama kutu daun.";
      recommendations = [
        "Tidak ada obat untuk penyakit virus tanaman. Segera cabut dan bakar tanaman yang sakit agar tidak menular",
        "Kendalikan vektor penyebar (seperti kutu daun, thrips, kutu kebul) menggunakan insektisida organik atau kimia",
        "Cuci tangan dan sterilisasi alat sebelum dan sesudah memegang tanaman",
      ];
    } else if (label.contains('healthy')) {
      diseaseName = "Sehat";
      status = "Bebas Penyakit";
      severity = "Tidak Ada";
      analysisDescription =
          "Daun terlihat sehat dan tidak menunjukkan gejala infeksi jamur, bakteri, atau virus. Kondisi daun prima untuk mendukung fotosintesis.";
      recommendations = [
        "Lanjutkan penyiraman secara teratur tanpa menggenangi media tanam",
        "Berikan pemupukan secara berkala sesuai kebutuhan fase pertumbuhan",
        "Lakukan pemantauan rutin untuk mendeteksi dini serangan hama atau penyakit",
      ];
    }

    return DiseaseReport(
      label: rawLabel,
      diseaseName: diseaseName,
      scientificName: scientificName,
      status: status,
      accuracy: accuracyPercent,
      severity: severity,
      analysisDescription: analysisDescription,
      recommendations: recommendations,
    );
  }

  Future<bool> saveToHistory() async {
    if (reports.isEmpty) return false;
    final primary = reports[0];
    final record = ScanHistoryRecord(
      id: const Uuid().v4(),
      conditionName: primary.diseaseName,
      accuracyPercent: primary.accuracy,
      isHealthy:
          primary.status.toLowerCase().contains('sehat') ||
          primary.status.toLowerCase().contains('bebas'),
      isSynced: false,
      scannedAt: DateTime.now(),
    );
    await HistoryService().save(record);
    SyncService().trySyncPending();
    return true;
  }
}
