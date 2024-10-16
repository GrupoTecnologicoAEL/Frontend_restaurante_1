import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_config.dart';
import 'router/app_router.dart' as router;
import 'package:provider/provider.dart';// Importación corregida de AuthProvider
import 'package:restaurante_1/Screens/login.dart'; // Importación corregida de login.dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las variables de entorno del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await initializeFirebase();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Proveer AuthProvider globalmente
      ],
      child: MaterialApp.router(
        title: 'Restaurante',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerDelegate: router.appRouter.routerDelegate,
        routeInformationParser: router.appRouter.routeInformationParser,
        routeInformationProvider: router.appRouter.routeInformationProvider,
      ),
    );
  }
}
