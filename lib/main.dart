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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0077C2)),
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

    // Si la pantalla es pequeña, usamos diseño en columna
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9),
      body: SafeArea(
        child: isMobile
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  /// 🌐 Diseño para pantallas grandes (imagen izquierda, login derecha)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Imagen izquierda
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/2.jpg"), // Cambia por tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Panel de login derecha
        Expanded(
          flex: 1,
          child: Center(
            child: _buildLoginCard(context, maxWidth: 450),
          ),
        ),
      ],
    );
  }

  /// 📱 Diseño para pantallas pequeñas (todo en columna)
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: _buildLoginCard(context, maxWidth: 380),
      ),
    );
  }

  /// 💳 Tarjeta de login
  Widget _buildLoginCard(BuildContext context, {double maxWidth = 450}) {
    return Container(
      width: maxWidth,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo y título
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("img/logo.png", width: 80, height: 80),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DocTime',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Consultas y citas médicas',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            '¿Requieres Atención Médica?',
            style: TextStyle(
              color: Color(0xFF0077C2),
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Euclid Circular A',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Botón de iniciar sesión
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
          const SizedBox(height: 15),

          // Botón de registro
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
    );
  }
}
