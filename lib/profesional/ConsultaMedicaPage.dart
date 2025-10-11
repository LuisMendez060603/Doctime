import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'patient_dialog1.dart'; // Asegúrate de importar tu diálogo correctamente
import 'citas_page.dart'; // Asegúrate de importar la página de citas correctamente

class ConsultaMedicaPage extends StatefulWidget {
  final String correo;
  final String password;
  final Map<String, dynamic> cita;

  const ConsultaMedicaPage({
    super.key,
    required this.correo,
    required this.password,
    required this.cita,
  });

  @override
  State<ConsultaMedicaPage> createState() => _ConsultaMedicaPageState();
}

class _ConsultaMedicaPageState extends State<ConsultaMedicaPage> {
  final TextEditingController sintomasController = TextEditingController();
  final TextEditingController diagnosticoController = TextEditingController();
  final TextEditingController tratamientoController = TextEditingController();

  Map<String, dynamic>? datosPaciente;

  @override
  void initState() {
    super.initState();
    obtenerDatosPaciente();
  }

  Future<void> obtenerDatosPaciente() async {
    const url = 'http://localhost/doctime/BD/obtener_datos_paciente.php';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'clave_cita': widget.cita['Clave_Cita']}),
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        datosPaciente = data['paciente'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message']}')),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'img/Imagen5.png', // Asegúrate de tener esta imagen en assets
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                message,
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
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> guardarConsulta() async {
    // Verificación de campos vacíos
    if (sintomasController.text.isEmpty || diagnosticoController.text.isEmpty || tratamientoController.text.isEmpty) {
      _showErrorDialog('Por favor, complete todos los campos');
      return; // No guarda si los campos están vacíos
    }

    const url = 'http://localhost/doctime/BD/guardar_consulta.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'clave_cita': widget.cita['Clave_Cita'],
          'sintomas': sintomasController.text,
          'diagnostico': diagnosticoController.text,
          'tratamiento': tratamientoController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _showSuccessDialog(); // Llamamos al mensaje de éxito
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la consulta. Intente nuevamente.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'img/Imagen5.png', // Asegúrate de tener esta imagen en assets
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Consulta Guardada!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
             
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
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CitasPage(
                      correo: widget.correo,
                      password: widget.password,
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fecha = widget.cita['Fecha'] ?? 'Fecha no disponible';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("img/logo.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DocTime',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Consultas y citas médicas',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => PatientDialog1(
                          correo: widget.correo,
                          password: widget.password,
                        ),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("img/Imagen2.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              if (datosPaciente != null) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Datos del Paciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0077C2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("👤 ${datosPaciente!['Nombre']} ${datosPaciente!['Apellido']}",
                            style: const TextStyle(fontSize: 16)),
                        Text("📞 ${datosPaciente!['Telefono']}",
                            style: const TextStyle(fontSize: 16)),
                        Text("✉️ ${datosPaciente!['Correo']}",
                            style: const TextStyle(fontSize: 16)),
                        Text("📅 Fecha de cita: $fecha",
                            style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ] else
                const Center(child: CircularProgressIndicator()),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Consulta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0077C2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Síntomas
                        const Text('Síntomas', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100], // Color de fondo más suave
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!, width: 1), // Línea más suave
                          ),
                          child: TextField(
                            controller: sintomasController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Escribe aquí los síntomas...',
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Diagnóstico
                        const Text('Diagnóstico', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100], // Color de fondo más suave
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!, width: 1), // Línea más suave
                          ),
                          child: TextField(
                            controller: diagnosticoController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Escribe el diagnóstico...',
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tratamiento
                        const Text('Tratamiento', style: TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100], // Color de fondo más suave
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!, width: 1), // Línea más suave
                          ),
                          child: TextField(
                            controller: tratamientoController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Escribe el tratamiento...',
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Botones fuera del contenedor del formulario
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: guardarConsulta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077C2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077C2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Volver',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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
