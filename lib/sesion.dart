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
              Image.asset(
                'img/Imagen5.png',
                height: 100,
                width: 100,
              ),
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

    // Cierra el diálogo automáticamente después de 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Cierra el diálogo
        onAceptar(); // Ejecuta la acción de navegación
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
              Image.asset(
                'img/Imagen5.png',
                height: 100,
                width: 100,
              ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F9), // Fondo azul agua
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0077C2)),
        title: const SizedBox.shrink(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, // Tarjeta blanca
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo y título
                Container(
                  width: double.infinity,
                  height: 110,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          padding: const EdgeInsets.only(left: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'DocTime',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
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
                const SizedBox(height: 10),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Color(0xFF0077C2),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 332,
                  child: Column(
                    children: [
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
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _iniciarSesion,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.hovered)) return const Color(0xFF005EA6);
                            if (states.contains(MaterialState.pressed)) return const Color(0xFF004B84);
                            return const Color(0xFF0077C2);
                          }),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          minimumSize: MaterialStateProperty.all(const Size(332, 55)),
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
                      const SizedBox(height: 10),
                      TextButton(
  onPressed: () {
    // Aquí es donde navegas al archivo contraseña.dart
    Navigator.push(
      context,
      MaterialPageRoute(
        // Utiliza el nombre de la CLASE que está en contraseña.dart
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
