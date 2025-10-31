import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerConsulta extends StatelessWidget {
	final Map<String, dynamic> cita;
	

  const VerConsulta({
    super.key,
    required this.cita,
    
  });
			Future<Map<String, dynamic>?> obtenerConsulta() async {
				final url = Uri.parse('http://localhost/doctime/BD/obtener_consulta.php');
				final response = await http.post(
					url,
					body: jsonEncode({
						
						'clave_cita': cita['clave_cita'] ?? cita['Clave_Cita'] ?? '',
					}),
					headers: {'Content-Type': 'application/json'},
				);
				final data = jsonDecode(response.body);
				if (data['success'] && data['consulta'] != null) {
					return data['consulta'];
				}
				return null;
			}

		@override
		Widget build(BuildContext context) {
			return Scaffold(
				appBar: AppBar(
					title: const Text('Detalle de consulta'),
					backgroundColor: const Color(0xFF0077C2),
				),
				body: Padding(
					padding: const EdgeInsets.all(20.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text('Fecha: ${cita['fecha']}', style: const TextStyle(fontSize: 18)),
							const SizedBox(height: 10),
							Text('Hora: ${cita['hora']}', style: const TextStyle(fontSize: 18)),
							const SizedBox(height: 10),
							Text('Profesional: ${cita['profesional']}', style: const TextStyle(fontSize: 18)),
							const SizedBox(height: 10),
							Text('Estado: ${cita['estado']}', style: const TextStyle(fontSize: 18)),
							const SizedBox(height: 20),
							FutureBuilder<Map<String, dynamic>?>(
								future: obtenerConsulta(),
								builder: (context, snapshot) {
									if (snapshot.connectionState == ConnectionState.waiting) {
										return const Center(child: CircularProgressIndicator());
									}
									if (snapshot.hasError) {
										return const Text('Error al cargar la consulta');
									}
									final consulta = snapshot.data;
									if (consulta == null) {
										return const Text('No hay datos de consulta para esta cita');
									}
									return Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text('Síntomas: ${consulta['sintomas']}', style: const TextStyle(fontSize: 18)),
											const SizedBox(height: 10),
											Text('Diagnóstico: ${consulta['diagnostico']}', style: const TextStyle(fontSize: 18)),
											const SizedBox(height: 10),
											Text('Tratamiento: ${consulta['tratamiento']}', style: const TextStyle(fontSize: 18)),
										],
									);
								},
							),
						],
					),
				),
			);
		}
}
