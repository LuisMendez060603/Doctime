import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pdf_generator.dart';
import 'patient_dialog.dart';

class VerConsulta extends StatelessWidget {
  final Map<String, dynamic> cita;
  final String correo;
  final String password;

  const VerConsulta({
    super.key,
    required this.cita,
    required this.correo,
    required this.password,
  });

  Future<Map<String, dynamic>?> obtenerConsulta() async {
    final url = Uri.parse('http://localhost/doctime/BD/obtener_consulta.php');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          'clave_cita': cita['clave_cita'] ?? cita['Clave_Cita'] ?? '',
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] && data['consulta'] != null) {
          return data['consulta'];
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error al obtener consulta: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Cabecera
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isSmallScreen ? 50 : 60,
                          height: isSmallScreen ? 50 : 60,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("img/logo.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DocTime',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('Consultas y citas médicas',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              PatientDialog(correo: correo, password: password),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("img/Imagen2.png"),
                              fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Card con detalles
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: obtenerConsulta(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Text('Error al cargar la consulta');
                        }

                        final consulta = snapshot.data;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Detalle de la Cita',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0077C2))),
                            const SizedBox(height: 10),

                            // Nombre del paciente
                            if (consulta != null &&
                                consulta['nombre_paciente'] != null)
                              Text("👤 Paciente: ${consulta['nombre_paciente']}",
                                  style: const TextStyle(fontSize: 16)),

                            Text("📅 Fecha: ${cita['fecha']}",
                                style: const TextStyle(fontSize: 16)),
                            Text("⏰ Hora: ${cita['hora']}",
                                style: const TextStyle(fontSize: 16)),
                            Text("👨‍⚕️ Profesional: ${consulta?['nombre_profesional'] ?? cita['profesional'] ?? 'No disponible'}",
                                style: const TextStyle(fontSize: 16),
                                ),
                            const SizedBox(height: 15),
                            const Text('Datos de la Consulta',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0077C2))),
                            const SizedBox(height: 10),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10)),
                              child: consulta != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("📝 Síntomas:",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(consulta['sintomas'] ?? 'N/A',
                                            style: const TextStyle(fontSize: 16)),
                                        const SizedBox(height: 10),
                                        Text("💊 Diagnóstico:",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(consulta['diagnostico'] ?? 'N/A',
                                            style: const TextStyle(fontSize: 16)),
                                        const SizedBox(height: 10),
                                        Text("⚕️ Tratamiento:",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(consulta['tratamiento'] ?? 'N/A',
                                            style: const TextStyle(fontSize: 16)),
                                      ],
                                    )
                                  : const Text(
                                      'No hay datos de consulta para esta cita',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic)),
                            ),
                            const SizedBox(height: 20),

                            // Botón PDF
                            SizedBox(
                              width: isSmallScreen ? 140 : 180,
                              child: ElevatedButton(
                                onPressed: () =>
                                    PdfGenerator.generarPDF(context, cita, consulta),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Descargar PDF',
                                    style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Botón Volver
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
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text('Volver',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
