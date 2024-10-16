//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

Future<void> initializeFirebase() async {
  // Inicializar Firebase con las variables de entorno del archivo .env
  FirebaseApp app = await Firebase.initializeApp(
  options: FirebaseOptions(
    /*apiKey: dotenv.env['API_KEY'] ?? 'default_api_key', 
    authDomain: dotenv.env['AUTH_DOMAIN'] ?? 'default_auth_domain',
    projectId: dotenv.env['PROJECT_ID'] ?? 'default_project_id',
    storageBucket: dotenv.env['STORAGE_BUCKET'] ?? 'default_storage_bucket',
    messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? 'default_sender_id',
    appId: dotenv.env['APP_ID'] ?? 'default_app_id',
    measurementId: dotenv.env['MEASUREMENT_ID'] ?? 'default_measurement_id',*/
      apiKey: 'AIzaSyDdClQ2QdiWo9YuvA5D37G44MqZ1hld2LU', 
    authDomain: 'restaurante-1-61b52.firebaseapp.com',
    projectId: 'restaurante-1-61b52',
    storageBucket: 'restaurante-1-61b52.appspot.com',
    messagingSenderId: '845819342423',
    appId: '1:845819342423:web:7c41dd54afd3a4a6713d12',
    measurementId: 'G-ECH565D6G3',
  ),
);

  // Inicializar Firebase Analytics si lo estás usando
  FirebaseAnalytics analytics = FirebaseAnalytics.instanceFor(app: app);
}
