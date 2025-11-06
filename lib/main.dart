import 'package:doctime/registrarse.dart';
import 'package:doctime/sesion.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'database_helper.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 500 ? 480.0 : screenWidth - 40;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), // Fondo suave
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo y título
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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
                const SizedBox(height: 10),
                // Mensaje de bienvenida
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: const [
                      Text(
                        '¿Requieres Atención Médica?',
                        style: TextStyle(
                          color: Color(0xFF0077C2),
                          fontSize: 23,
                          fontFamily: 'Euclid Circular A',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Botones
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFF005A9C); 
                            }
                            return const Color(0xFF0077C2); 
                          }),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(332, 47)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IniciarSesionPage()),
                          );
                        },
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Euclid Circular A',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return const Color(0xFF005A9C); 
                            }
                            return const Color(0xFF0077C2); 
                          }),
                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(332, 47)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrarsePage()),
                          );
                        },
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Euclid Circular A',
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
      ),
    );
  }
}
