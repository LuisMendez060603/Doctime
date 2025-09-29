import 'package:doctime/registrarse.dart';
import 'package:doctime/sesion.dart'; // Importa sesion.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Agregado para localización
import 'database_helper.dart'; // Importa el helper de base de datos

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Verifica la conexión a la base de datos al inicio
  DatabaseHelper.verificarConexion();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocTime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 12, 12, 12)),
      ),
      // Configuración de localizaciones
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // Inglés (si lo necesitas)
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      body: Center(
        child: Container(
          width: 420,
          height: 829,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo y título
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                padding: const EdgeInsets.all(5),
                                child: Image.asset("img/logo.png"),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DocTime',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Consultas y citas médicas',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0),
              // Mensaje de bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: const [
                    Text(
                        '¿Requieres Atención Médica?',
                        style: TextStyle(
                         color: const Color(0xFF0077C2),
                          fontSize: 23,
                          fontFamily: 'Euclid Circular A',
                          fontWeight: FontWeight.bold, // 👈 Negritas
                        ),
                      ),
                    SizedBox(height: 15),
                    Text(
                      'Inicia sesión o regístrate para poder agendar tu cita\ny ponernos en contacto contigo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Euclid Circular A',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Botones con un tamaño y espaciado similar al segundo fragmento
              Container(
                width: double.infinity,
                height: 208,
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077C2),
                        minimumSize: const Size(332, 47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Navegar a la página de inicio de sesión
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const IniciarSesionPage()),
                        );
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Más grande
                          fontWeight: FontWeight.bold, // Más gruesa
                          fontFamily: 'Euclid Circular A', // Opcional, si la tienes en tu proyecto
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                       backgroundColor: const Color(0xFF0077C2),
                        minimumSize: const Size(332, 47),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Navegar a la página de registro
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrarsePage()),
                        );
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Más grande
                          fontWeight: FontWeight.bold, // Más gruesa
                          fontFamily: 'Euclid Circular A', // Opcional, si la tienes en tu proyecto
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
