import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sesion.dart';

class RecuperacionContrasenaScreen extends StatefulWidget {
  const RecuperacionContrasenaScreen({super.key});

  @override
  State<RecuperacionContrasenaScreen> createState() =>
      _RecuperacionContrasenaScreenState();
}

class _RecuperacionContrasenaScreenState
    extends State<RecuperacionContrasenaScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  final String _recoveryUrl =
      'http://localhost/doctime/BD/recover_password.php';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendNewPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showAlert('Por favor, introduce un correo electrónico válido.',
          isSuccess: false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_recoveryUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        _showAlert(responseData['message'], isSuccess: true);

        // Espera 3 segundos y luego navega al login
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const IniciarSesionPage()),
        );

      } else {
        _showAlert(responseData['message'] ?? 'Ocurrió un error inesperado.',
            isSuccess: false);
      }
    } catch (e) {
      _showAlert(
          'Error de conexión. Verifica tu servidor PHP o tu red.',
          isSuccess: false);
      print('Error al solicitar nueva contraseña: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String message, {required bool isSuccess}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'img/Imagen4.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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
      backgroundColor: const Color(0xFFF0F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0077C2)),
        title: const SizedBox.shrink(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              const SizedBox(height: 20),
              const Text(
                'Generaremos y enviaremos una nueva contraseña a tu correo electrónico.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              // TextFormField con diseño azul
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: const TextStyle(color: Color(0xFF0077C2)),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF0077C2)),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF0077C2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF0077C2), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botón azul con hover
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendNewPassword,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return const Color(0xFF005EA3);
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return Colors.grey;
                      }
                      return const Color(0xFF0077C2);
                    }),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 15),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar Nueva Contraseña',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
