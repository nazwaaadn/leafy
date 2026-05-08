class AppConstants {
  static const double confidenceThreshold = 0.5;
  static const int modelInputSize = 640;

  static const String mongoAppId = 'YOUR_APP_ID';
  static const String mongoApiKey = 'YOUR_API_KEY';
  static const String mongoDataSource = 'Cluster0';
  static const String mongoDatabase = 'leafy_db';
  static const String mongoCollection = 'detections';

  static const String mongoBaseUrl =
      'https://data.mongodb-api.com/app/$mongoAppId/endpoint/data/v1';
}
