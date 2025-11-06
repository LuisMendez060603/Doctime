// En el archivo: contraseña.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecuperacionContrasenaScreen extends StatefulWidget {
  const RecuperacionContrasenaScreen({super.key});

  @override
  State<RecuperacionContrasenaScreen> createState() => _RecuperacionContrasenaScreenState();
}

class _RecuperacionContrasenaScreenState extends State<RecuperacionContrasenaScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // ¡Ajusta esta URL si usas emulador de Android (http://10.0.2.2/...)!
  final String _recoveryUrl = 'http://localhost/doctime/BD/recover_password.php'; 

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendNewPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Por favor, introduce un correo electrónico válido.', isSuccess: false);
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
        _showSnackBar(responseData['message'], isSuccess: true);
        
        // Espera un momento y regresa al Login para que el usuario use la nueva contraseña
        await Future.delayed(const Duration(seconds: 3));
        Navigator.pop(context); 

      } else {
        // En caso de error en la DB o envío de correo
        _showSnackBar(responseData['message'] ?? 'Ocurrió un error inesperado.', isSuccess: false);
      }
    } catch (e) {
      _showSnackBar('Error de conexión. Verifica tu servidor PHP o tu red.', isSuccess: false);
      print('Error al solicitar nueva contraseña: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer Contraseña'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Generaremos y enviaremos una nueva contraseña a tu correo electrónico.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendNewPassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Enviar Nueva Contraseña', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}