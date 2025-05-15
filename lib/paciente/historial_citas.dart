import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modificar_cita.dart';
import 'patient_dialog.dart';

class HistorialCitas extends StatefulWidget {
  final String correo;
  final String password;

  const HistorialCitas({super.key, required this.correo, required this.password});

  @override
  State<HistorialCitas> createState() => _HistorialCitasState();
}

class _HistorialCitasState extends State<HistorialCitas> {
  List<Map<String, dynamic>> citasPendientes = [];
  List<Map<String, dynamic>> citasPasadas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerCitas();
  }

  Future<void> obtenerCitas() async {
    final url = Uri.parse('http://localhost/doctime/obtener_citas_paciente.php');
    final response = await http.post(
      url,
      body: jsonEncode({
        'correo': widget.correo,
        'password': widget.password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      final hoy = DateTime.now();
      final citas = List<Map<String, dynamic>>.from(data['citas']);

      List<Map<String, dynamic>> pendientes = [];
      List<Map<String, dynamic>> pasadas = [];

      for (var cita in citas) {
        final fecha = DateTime.parse(cita['fecha']);
        final estado = cita['estado'] ?? 'Activa';

        if (estado == 'Cancelada' || fecha.isBefore(hoy)) {
          pasadas.add(cita);
        } else {
          pendientes.add(cita);
        }
      }

      setState(() {
        citasPendientes = pendientes;
        citasPasadas = pasadas;
        cargando = false;
      });
    } else {
      setState(() {
        cargando = false;
      });
      print('Error: ${data['message']}');
    }
  }

  Future<void> cancelarCita(Map<String, dynamic> cita) async {
    final url = Uri.parse('http://localhost/doctime/cancelar_cita.php');
    final response = await http.post(
      url,
      body: jsonEncode({
        'correo': widget.correo,
        'password': widget.password,
        'fecha': cita['fecha'],
        'hora': cita['hora'],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        cita['estado'] = 'Cancelada';
        citasPendientes.remove(cita);
        citasPasadas.add(cita);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar cita: ${data['message']}')),
      );
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
          // El contenido principal que se desplaza
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
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
                              image: AssetImage("img/Imagen1.png"),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DocTime',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                                fontFamily: 'Euclid Circular A',
                              ),
                            ),
                            Text(
                              'Consultas y citas médicas',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => PatientDialog(
                            correo: widget.correo,
                            password: widget.password,
                          ),
                        );
                      },
                      child: Container(
                        width: isSmallScreen ? 50 : 60,
                        height: isSmallScreen ? 50 : 60,
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

                // Lista de citas (pendientes, pasadas)
                if (cargando)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const Text('Citas Pendientes',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...citasPendientes.map(
                        (cita) => CitaCard(
                          cita: cita,
                          color: Colors.blue[100]!,
                          onCancelar: () => cancelarCita(cita),
                          onModificar: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModificarCita(
                                  correo: widget.correo,
                                  password: widget.password,
                                  cita: cita,
                                  claveProfesional: '7',
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Text('Citas Pasadas',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...citasPasadas.map(
                        (cita) => CitaCard(
                          cita: cita,
                          color: cita['estado'] == 'Cancelada'
                              ? Colors.red[100]!
                              : Colors.grey[300]!,
                          cancelada: cita['estado'] == 'Cancelada',
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),
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
                    backgroundColor: const Color(0xFF00ADFF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

class CitaCard extends StatelessWidget {
  final Map<String, dynamic> cita;
  final Color color;
  final VoidCallback? onCancelar;
  final VoidCallback? onModificar;
  final bool cancelada;

  const CitaCard({
    super.key,
    required this.cita,
    required this.color,
    this.onCancelar,
    this.onModificar,
    this.cancelada = false,
  });

  @override
  Widget build(BuildContext context) {
    // Detectar los estados
    bool confirmada = cita['estado'].toString().toLowerCase().contains('confirmada');
    bool modificada = cita['estado'].toString().toLowerCase().contains('modificada');
    bool cancelada = cita['estado'] == 'Cancelada';

    return Card(
      color: color,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${cita['fecha']} - ${cita['hora']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Con ${cita['profesional']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Mostrar el estado de la cita (Confirmada, Cancelada, Modificada)
            if (cancelada)
              const Text(
                'Cancelada',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            if (modificada)
              const Text(
                'Modificada',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            if (confirmada)
              const Text(
                'Confirmada',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            
            // Mostrar botones para modificar o cancelar la cita
            if (onCancelar != null && onModificar != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onModificar,
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text('Modificar', style: TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onCancelar,
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
