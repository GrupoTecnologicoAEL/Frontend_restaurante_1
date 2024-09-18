import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_config.dart';
import 'router/app_router.dart' as router;
import 'Screens/login.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las variables de entorno del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await initializeFirebase();

  // Obtener el Client ID de Google desde el archivo .env
  final String googleClientId = dotenv.env['GOOGLE_CLIENT_ID']!;

  // Inicializar Google Sign-In con el Client ID cargado desde .env
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: googleClientId,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurante',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: router.appRouter.routerDelegate,
      routeInformationParser: router.appRouter.routeInformationParser,
      routeInformationProvider: router.appRouter.routeInformationProvider
    );
  }
}
