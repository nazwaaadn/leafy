import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leafy_app/core/routes/app_routes.dart';
import 'package:leafy_app/data/services/connectivity_service.dart';
import 'package:leafy_app/data/services/hive_service.dart';
import 'package:leafy_app/data/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await HiveService().init();
  await ConnectivityService().init();
  SyncService().init();

  runApp(const LeafyApp());
}

class LeafyApp extends StatelessWidget {
  const LeafyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Leafy',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
