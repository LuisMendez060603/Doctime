import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sesion.dart'; // <-- Importa tu pantalla de inicio de sesión

class ConfirmarCorreoPage extends StatefulWidget {
  final String correo;
  const ConfirmarCorreoPage({super.key, required this.correo});

  @override
  _ConfirmarCorreoPageState createState() => _ConfirmarCorreoPageState();
}

class _ConfirmarCorreoPageState extends State<ConfirmarCorreoPage> {
  final TextEditingController _codigoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      _showWarningDialog("Ingresa el código");
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://localhost/doctime/BD/verificar_codigo.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"correo": widget.correo, "codigo": codigo}),
      );

      final data = jsonDecode(response.body);
      if (data["estado"] == "ok") {
        _showSuccessDialog("¡Registro Exitoso!");
      } else {
        _showWarningDialog(data["mensaje"]);
      }
    } catch (e) {
      _showWarningDialog("Error de conexión.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String mensaje) {
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
              Text(
                mensaje,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => IniciarSesionPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(String mensaje) {
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
              Text(
                mensaje,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Cerrar',
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 400;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
            child: Column(
              children: [
                // HEADER con logo y texto
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Image.asset("img/logo.png", fit: BoxFit.contain),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Ingresa el código que enviamos a tu correo",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _codigoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Código de verificación",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verificarCodigo,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verificar"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white, // <-- Aquí ponemos el texto blanco
                  ),
                ),

                SizedBox(height: 100), // espacio para que no choque con botón volver
              ],
            ),
          ),
          // BOTÓN VOLVER
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: isSmallScreen ? 140 : 180,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Volver',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
