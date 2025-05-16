import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../sesion.dart';

class PatientDialog1 extends StatefulWidget {
  final String correo;
  final String password;

  const PatientDialog1({required this.correo, required this.password});

  @override
  _PatientDialogState createState() => _PatientDialogState();
}

class _PatientDialogState extends State<PatientDialog1> {
  String? nombre;
  String? apellido;
  String? especialidad;
  String? telefono;
  String? direccion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfessionalData();
  }

  Future<void> _fetchProfessionalData() async {
    final response = await http.post(
      Uri.parse('http://localhost/doctime/BD/iniciar_sesion.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'correo': widget.correo,
        'password': widget.password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] && data['tipo_usuario'] == "profesional") {
        setState(() {
          nombre = data['nombre'];
          apellido = data['apellido'];
          especialidad = data['especialidad'];
          telefono = data['telefono'];
          direccion = data['direccion'];
          _isLoading = false;
        });
      } else {
        _showErrorDialog(context, data['message']);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorDialog(context, 'Error de conexión');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const IniciarSesionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 350,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Datos del Profesional',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    _infoRow("Nombre", nombre),
                    _infoRow("Apellido", apellido),
                    _infoRow("Especialidad", especialidad),
                    _infoRow("Teléfono", telefono),
                    _infoRow("Correo", widget.correo),
                    _infoRow("Dirección", direccion),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () => _cerrarSesion(context),
                          child: const Text('Cerrar sesión'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value ?? 'No disponible',
            ),
          ],
        ),
      ),
    );
  }
}
