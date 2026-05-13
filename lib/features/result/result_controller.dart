class ResultController {
  final String diseaseName = "Bercak Daun";
  final String scientificName = "(Leaf Spot)";
  final String status = "Terinfeksi";
  final double accuracy = 85.4;
  final String severity = "Sedang";
  final String analysisDescription =
      "Ditemukan bercak berwarna kuning kecoklatan pada area tengah daun, diakibatkan oleh patogen jamur \"Cercospora\". Kondisi cuaca lembab mempercepat penyebaran.";

  final List<String> recommendations = [
    "Isolasi atau pangkas daun yang terinfeksi parah agar jamur tidak menyebar",
    "Aplikasikan fungisida berbahan aktif tembaga atau mankozeb pada pagi hari",
    "Kurangi intensitas penyiraman pada area daun, siram langsung ke area perakaran",
  ];

  void saveToHistory() {
    print("Data disimpan ke riwayat...");
  }
}
