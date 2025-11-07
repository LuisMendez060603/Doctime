import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'paciente/paciente1.dart' as paciente;
import 'profesional/profesional1.dart' as profesional;
import 'main.dart';
import 'registrarse.dart';
import 'contraseña.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({super.key});

  @override
  _IniciarSesionPageState createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _iniciarSesion() async {
    final url = Uri.parse('http://localhost/doctime/BD/iniciar_sesion.php');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "correo": _correoController.text,
        "password": _passwordController.text,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (responseData["success"]) {
      print("Bienvenido: ${responseData["message"]}");

      String tipoUsuario = responseData["tipo_usuario"];

      if (tipoUsuario == "paciente") {
        _mostrarDialogoExito(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => paciente.Paciente1(
                correo: _correoController.text,
                password: _passwordController.text,
              ),
            ),
          );
        });
      } else if (tipoUsuario == "profesional") {
        _mostrarDialogoExito(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => profesional.Profesional1(
                correo: _correoController.text,
                password: _passwordController.text,
              ),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tipo de usuario desconocido")),
        );
      }
    } else {
      _mostrarDialogoError();
    }
  }

  void _mostrarDialogoExito(VoidCallback onAceptar) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('img/Imagen5.png', height: 100, width: 100),
              const SizedBox(height: 10),
              const Text(
                '¡Inicio de sesión exitoso!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        onAceptar();
      }
    });
  }

  void _mostrarDialogoError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('img/Imagen5.png', height: 100, width: 100),
              const SizedBox(height: 10),
              const Text(
                'Correo o contraseña incorrectos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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

  /// 🌐 Diseño para pantallas grandes (formulario izquierda, imagen derecha)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // 🩺 Panel de login (izquierda)
        Expanded(
          flex: 1,
          child: Center(
            child: SingleChildScrollView(
              child: _buildLoginCard(context, maxWidth: 420),
            ),
          ),
        ),

        // 🖼️ Imagen derecha
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/2.jpg"), // tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📱 Diseño móvil (solo el formulario centrado)
  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: _buildLoginCard(context, maxWidth: 380),
      ),
    );
  }

  /// 💳 Tarjeta de login reutilizable
  Widget _buildLoginCard(BuildContext context, {double maxWidth = 420}) {
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
          // 🔙 Flecha de regreso
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              },
            ),
          ),

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
            'Iniciar Sesión',
            style: TextStyle(
              color: Color(0xFF0077C2),
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Campos de texto
          TextField(
            controller: _correoController,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.black),
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: const TextStyle(color: Colors.black),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón principal
          ElevatedButton(
            onPressed: _iniciarSesion,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.hovered)) return const Color(0xFF005EA6);
                if (states.contains(MaterialState.pressed)) return const Color(0xFF004B84);
                return const Color(0xFF0077C2);
              }),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              minimumSize: MaterialStateProperty.all(const Size(double.infinity, 55)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
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

          // Links
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecuperacionContrasenaScreen(),
                ),
              );
            },
            child: const Text('¿Olvidaste tu contraseña?'),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistrarsePage()),
              );
            },
            child: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }
}
