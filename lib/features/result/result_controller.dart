import '../../data/models/detection_item.dart';

class ResultController {
  String diseaseName = "Tidak Diketahui";
  String scientificName = "";
  String status = "Aman";
  double accuracy = 0.0;
  String severity = "Rendah";
  String analysisDescription = "Tidak ada informasi analisis yang tersedia.";
  List<String> recommendations = [];

  ResultController(List<DetectionItem> detections) {
    if (detections.isNotEmpty) {
      // Cari dengan confidence tertinggi
      final bestDetection = detections.reduce(
        (a, b) => a.confidence > b.confidence ? a : b,
      );
      
      accuracy = double.parse((bestDetection.confidence * 100).toStringAsFixed(1));
      
      _mapLabelToInfo(bestDetection.label);
    } else {
      diseaseName = "Tidak Terdeteksi";
      scientificName = "No Detections";
      status = "Tidak Teridentifikasi";
      severity = "-";
      analysisDescription = "Model tidak dapat mendeteksi adanya pola penyakit atau daun pada gambar. Pastikan gambar cukup terang, fokus, dan objek daun terlihat dengan jelas.";
      recommendations = [
        "Pastikan daun berada di tengah frame kamera",
        "Coba ambil gambar dengan pencahayaan yang lebih terang",
        "Dekatkan kamera ke objek daun (hindari latar belakang yang terlalu ramai)"
      ];
    }
  }

  void _mapLabelToInfo(String rawLabel) {
    final label = rawLabel.toLowerCase();
    
    if (label.contains('spot')) {
      diseaseName = "Bercak Daun";
      scientificName = "($rawLabel)";
      status = "Terinfeksi";
      severity = "Sedang";
      analysisDescription = "Ditemukan bercak pada area daun yang terdeteksi sebagai '$rawLabel', umumnya diakibatkan oleh patogen jamur atau bakteri. Kondisi cuaca lembab dapat mempercepat penyebaran.";
      recommendations = [
        "Pangkas dan musnahkan daun yang terinfeksi parah agar jamur tidak menyebar",
        "Aplikasikan fungisida berbahan aktif tembaga atau mankozeb pada pagi hari jika infeksi meluas",
        "Kurangi intensitas penyiraman pada area daun, siram langsung ke area perakaran"
      ];
    } else if (label.contains('blight')) {
      diseaseName = "Hawar Daun";
      scientificName = "($rawLabel)";
      status = "Terinfeksi";
      severity = "Tinggi";
      analysisDescription = "Daun menunjukkan gejala hawar (blight) dengan area mati berwarna coklat atau kehitaman yang luas. Penyakit '$rawLabel' ini menyebar dengan cepat dan dapat merusak seluruh tanaman jika tidak segera ditangani.";
      recommendations = [
        "Segera potong dan buang bagian tanaman yang terinfeksi jauh dari lokasi tanam",
        "Gunakan fungisida sistemik yang sesuai untuk menghentikan penyebaran",
        "Pastikan sirkulasi udara yang baik di sekitar tanaman dengan menjaga jarak tanam"
      ];
    } else if (label.contains('mildew')) {
      diseaseName = "Embun Tepung";
      scientificName = "($rawLabel)";
      status = "Terinfeksi";
      severity = "Sedang";
      analysisDescription = "Terdapat lapisan serbuk putih seperti tepung pada permukaan daun. Penyakit embun tepung ($rawLabel) ini menghambat fotosintesis dan membuat daun mengering.";
      recommendations = [
        "Semprotkan fungisida berbasis sulfur atau kalium bikarbonat sesuai dosis",
        "Hindari kelembaban yang terlalu tinggi terutama di malam hari",
        "Hindari menyiram daun dari atas (lakukan penyiraman di pangkal batang)"
      ];
    } else if (label.contains('rust')) {
      diseaseName = "Karat Daun";
      scientificName = "($rawLabel)";
      status = "Terinfeksi";
      severity = "Tinggi";
      analysisDescription = "Terdapat bintik-bintik berwarna oranye atau karat kemerahan pada bagian bawah atau atas daun. Penyakit karat daun ($rawLabel) sangat menular melalui spora yang terbawa angin.";
      recommendations = [
        "Segera pangkas dan singkirkan semua daun yang terinfeksi karat",
        "Gunakan fungisida tembaga atau fungisida sistemik secara rutin",
        "Sterilkan alat berkebun setelah memangkas tanaman yang terinfeksi agar tidak menular ke tanaman sehat"
      ];
    } else if (label.contains('mosaic') || label.contains('virus')) {
      diseaseName = "Virus Mosaik / Keriting";
      scientificName = "($rawLabel)";
      status = "Terinfeksi";
      severity = "Sangat Tinggi";
      analysisDescription = "Daun mengalami perubahan warna belang-belang kuning hijau (mosaik), mengerut, dan pertumbuhan terhambat akibat infeksi virus ($rawLabel). Penyakit ini umumnya ditularkan oleh hama kutu daun.";
      recommendations = [
        "Tidak ada obat untuk penyakit virus tanaman. Segera cabut dan bakar tanaman yang sakit agar tidak menular",
        "Kendalikan vektor penyebar (seperti kutu daun, thrips, kutu kebul) menggunakan insektisida organik atau kimia",
        "Cuci tangan dan sterilisasi alat sebelum dan sesudah memegang tanaman"
      ];
    } else if (label.contains('healthy')) {
      diseaseName = "Sehat";
      scientificName = "($rawLabel)";
      status = "Bebas Penyakit";
      severity = "Tidak Ada";
      analysisDescription = "Daun terlihat sehat dan tidak menunjukkan gejala infeksi jamur, bakteri, atau virus. Kondisi daun prima untuk mendukung fotosintesis.";
      recommendations = [
        "Lanjutkan penyiraman secara teratur tanpa menggenangi media tanam",
        "Berikan pemupukan secara berkala sesuai kebutuhan fase pertumbuhan",
        "Lakukan pemantauan rutin untuk mendeteksi dini serangan hama atau penyakit"
      ];
    } else {
      // Default fallback untuk kelas spesifik lainnya (misal: Insects Damages, Charcoal, Smut, Wilt, dll.)
      diseaseName = rawLabel;
      scientificName = "Crop Condition";
      status = "Terdeteksi";
      severity = "Perlu Pemeriksaan";
      analysisDescription = "Model mendeteksi kondisi '$rawLabel' pada daun tanaman. Kondisi ini memerlukan perhatian untuk memastikan tidak mengganggu kesehatan tanaman secara keseluruhan.";
      recommendations = [
        "Pantau perkembangan gejala ini pada daun lainnya",
        "Lakukan sanitasi kebun dengan membersihkan daun kering dan gulma",
        "Gunakan aplikasi pengendali hama jika terdapat tanda-tanda kerusakan fisik oleh serangga"
      ];
    }
  }

  void saveToHistory() {
    print("Data disimpan ke riwayat...");
  }
}
