import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'modificar_cita.dart';
import 'patient_dialog.dart';
import 'ver_consulta.dart';

class HistorialCitas extends StatefulWidget {
  final String correo;
  final String password;

  const HistorialCitas({super.key, required this.correo, required this.password});

  @override
  State<HistorialCitas> createState() => _HistorialCitasState();
}

class _HistorialCitasState extends State<HistorialCitas> {
  bool cargando = true;
  List citasPendientes = [];
  List citasPasadas = [];
  bool mostrarPendientes = true;

  @override
  void initState() {
    super.initState();
    obtenerCitas();
  }

  Future<void> obtenerCitas() async {
    final url = Uri.parse('http://localhost/doctime/BD/obtener_citas_paciente.php');
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
      final hoySinHora = DateTime(hoy.year, hoy.month, hoy.day);
      final citas = List<Map<String, dynamic>>.from(data['citas']);

      List<Map<String, dynamic>> pendientes = [];
      List<Map<String, dynamic>> pasadas = [];

      for (var cita in citas) {
        final fecha = DateTime.parse(cita['fecha']);
        final fechaSinHora = DateTime(fecha.year, fecha.month, fecha.day);
        final estado = cita['estado'] ?? 'Activa';

        if (estado == 'Cancelada' || fechaSinHora.isBefore(hoySinHora)) {
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
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'img/Imagen4.png',
              width: isSmallScreen ? 100 : 150,
              height: isSmallScreen ? 100 : 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              '¿Estás seguro que deseas cancelar esta cita?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('No', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Sí, cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmar != true) return;

    final url = Uri.parse('http://localhost/doctime/BD/cancelar_cita.php');
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

  void verCita(Map<String, dynamic> cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Detalle de consulta',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('img/Frame (7).png', width: 100, height: 100, fit: BoxFit.cover),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VerConsulta(
                        cita: cita,
                        correo: widget.correo,
                        password: widget.password,
                      ),
                    ),
                  );
                },
                child: const Text('Ver'),
              ),
            ),
          ],
        ),
      ),
    );
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
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
                            Text('DocTime', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text('Consultas y citas médicas', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w500)),
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => mostrarPendientes = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mostrarPendientes ? const Color(0xFF0077C2) : Colors.white,
                          foregroundColor: mostrarPendientes ? Colors.white : const Color(0xFF0077C2),
                          side: const BorderSide(color: Color(0xFF0077C2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Citas Pendientes'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => mostrarPendientes = false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !mostrarPendientes ? const Color(0xFF0077C2) : Colors.white,
                          foregroundColor: !mostrarPendientes ? Colors.white : const Color(0xFF0077C2),
                          side: const BorderSide(color: Color(0xFF0077C2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Citas Pasadas'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (cargando)
                  const Center(child: CircularProgressIndicator())
                else if (mostrarPendientes)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          onVer: () => verCita(cita),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      ...citasPasadas.map(
                        (cita) => CitaCard(
                          cita: cita,
                          color: cita['estado'] == 'Cancelada' ? Colors.red[100]! : Colors.grey[300]!,
                          cancelada: cita['estado'] == 'Cancelada',
                          onVer: () => verCita(cita),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Volver', style: TextStyle(fontSize: 18, color: Colors.white)),
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
  final VoidCallback? onVer;
  final bool cancelada;

  const CitaCard({
    super.key,
    required this.cita,
    required this.color,
    this.onCancelar,
    this.onModificar,
    this.onVer,
    this.cancelada = false,
  });

  @override
  Widget build(BuildContext context) {
    bool confirmada = cita['estado'].toString().toLowerCase().contains('confirmada');
    bool modificada = cita['estado'].toString().toLowerCase().contains('modificada');
    bool cancelada = cita['estado'] == 'Cancelada';

    return InkWell(
      onTap: onVer,
      child: Card(
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
              Text('Con ${cita['profesional']}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              if (cancelada)
                const Text('Cancelada', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              if (modificada)
                const Text('Modificada', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              if (confirmada)
                const Text('Confirmada', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
