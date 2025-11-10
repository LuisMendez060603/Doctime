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

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'clave_cita': widget.cita['Clave_Cita']}),
      );

      // DEBUG: imprimir todo para verificar qué devuelve el servidor
      print('obtenerDatosPaciente HTTP ${response.statusCode}: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          datosPaciente = Map<String, dynamic>.from(data['paciente'] ?? {});
        });

        // Si la respuesta no trajo la clave del paciente, intentar obtenerla desde la cita
        if (datosPaciente != null) {
          final fromPaciente = datosPaciente!['Clave_Paciente'] ??
              datosPaciente!['clave_paciente'] ??
              datosPaciente!['ClavePaciente'] ??
              datosPaciente!['id'] ??
              datosPaciente!['ID'];

          if (fromPaciente == null) {
            final fromCita = widget.cita['Clave_Paciente'] ??
                widget.cita['clave_paciente'] ??
                widget.cita['ClavePaciente'] ??
                widget.cita['PacienteID'] ??
                widget.cita['ID_Paciente'] ??
                widget.cita['id'];

            if (fromCita != null) {
              // añado la clave al mapa para que _verDatosClinicos la encuentre
              datosPaciente!['Clave_Paciente'] = fromCita;
              print('Clave_Paciente añadida a datosPaciente desde widget.cita: $fromCita');
            } else {
              // imprimir keys para depuración (usuario puede copiar/pegar en chat)
              print('No se encontró Clave_Paciente. Keys de datosPaciente: ${datosPaciente!.keys.toList()}');
              print('Keys de cita: ${widget.cita.keys.toList()}');
            }
          } else {
            print('Clave_Paciente encontrada en datosPaciente: $fromPaciente');
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['message']}')),
        );
      }
    } catch (e) {
      print('Error obtenerDatosPaciente: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener datos del paciente')),
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

  // Nuevo: solicitar datos clínicos y mostrarlos en un diálogo (diseño mejorado)
  Future<void> _verDatosClinicos() async {
    debugPrint('--- _verDatosClinicos llamado ---');

    // Obtener clavePaciente desde varios lugares
    String? clavePaciente;
    if (datosPaciente != null) {
      clavePaciente = datosPaciente!['Clave_Paciente']?.toString().trim() ??
          datosPaciente!['clave_paciente']?.toString().trim() ??
          datosPaciente!['ClavePaciente']?.toString().trim() ??
          datosPaciente!['id']?.toString().trim() ??
          datosPaciente!['ID']?.toString().trim();
    }
    clavePaciente ??= widget.cita['Clave_Paciente']?.toString().trim() ??
        widget.cita['clave_paciente']?.toString().trim() ??
        widget.cita['ID_Paciente']?.toString().trim() ??
        widget.cita['PacienteID']?.toString().trim();

    if (clavePaciente == null || clavePaciente.isEmpty) {
      // pedir a endpoint de cita si no hay clave
      try {
        final urlCita = 'http://localhost/doctime/BD/obtener_datos_paciente.php';
        final resp = await http.post(
          Uri.parse(urlCita),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'clave_cita': widget.cita['Clave_Cita']}),
        );
        debugPrint('obtener_datos_paciente HTTP ${resp.statusCode}: ${resp.body}');
        if (resp.statusCode == 200 && resp.body.trim().isNotEmpty) {
          final m = jsonDecode(resp.body);
          if (m['success'] == true) {
            final paciente = m['paciente'] ?? m['data'] ?? {};
            final posible = paciente is Map ? paciente['Clave_Paciente'] ?? paciente['clave_paciente'] ?? paciente['ID_Paciente'] ?? paciente['id'] : null;
            if (posible != null && posible.toString().trim().isNotEmpty) {
              clavePaciente = posible.toString().trim();
              datosPaciente ??= <String, dynamic>{};
              datosPaciente!['Clave_Paciente'] = clavePaciente;
              debugPrint('Clave_Paciente obtenida desde Clave_Cita: $clavePaciente');
            } else {
              _showErrorDialog('No se encontró Clave_Paciente en la respuesta de la cita.');
              return;
            }
          } else {
            _showErrorDialog(m['message'] ?? 'Error al obtener datos de la cita');
            return;
          }
        } else {
          _showErrorDialog('Error al consultar la cita: ${resp.statusCode}');
          return;
        }
      } catch (e) {
        debugPrint('Error al pedir Clave_Paciente desde cita: $e');
        _showErrorDialog('Error al obtener Clave_Paciente: $e');
        return;
      }
    }

    // Petición para obtener datos clínicos (envío JSON)
    final urlDatos = 'http://localhost/doctime/BD/obtener_datos_clinicos_simple.php';
    try {
      final response = await http.post(
        Uri.parse(urlDatos),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'clave_paciente': clavePaciente}),
      );

      debugPrint('obtener_datos_clinicos_simple HTTP ${response.statusCode}: ${response.body}');

      if (response.statusCode != 200) {
        _showErrorDialog('Error servidor: ${response.statusCode}');
        return;
      }
      final body = response.body.trim();
      if (body.isEmpty) {
        _showErrorDialog('Respuesta vacía del servidor');
        return;
      }

      final jsonResp = jsonDecode(body);
      if (jsonResp['success'] != true || jsonResp['data'] == null) {
        _showErrorDialog(jsonResp['message'] ?? 'No hay datos clínicos disponibles');
        return;
      }

      final Map<String, dynamic> d = Map<String, dynamic>.from(jsonResp['data']);

      // Campos a excluir de la visualización (no mostrar)
      final excludeLower = {'id_dato', 'clave_paciente', 'fecha_creacion', 'fecha_actualizacion'};

      // Etiquetas legibles y orden deseado
      final ordered = <String, String>{
        'nombre': 'Nombre',
        'apellido': 'Apellido',
        'edad': 'Edad',
        'sexo': 'Sexo',
        'fecha_nacimiento': 'Fecha Nacimiento',
        'curp': 'CURP',
        'telefono': 'Teléfono',
        'direccion': 'Dirección',
        'tipo_sangre': 'Tipo de sangre',
        'alergias': 'Alergias',
        'enfermedades_cronicas': 'Enfermedades crónicas',
        'medicamentos_actuales': 'Medicamentos actuales',
        'antecedentes_medicos': 'Antecedentes médicos',
        'observaciones': 'Observaciones',
        'peso': 'Peso',
        'altura': 'Altura',
        'fumador': 'Fumador',
        'consumo_alcohol': 'Consumo alcohol',
        'diabetes': 'Diabetes',
        'hipertension': 'Hipertensión',
        'cirugias_previas': 'Cirugías previas',
        'tabaquismo': 'Tabaquismo',
        'alcoholismo': 'Alcoholismo',
        'alimentacion': 'Alimentación',
        'ejercicio': 'Ejercicio',
        'padre': 'Padre',
        'madre': 'Madre',
        'hermanos': 'Hermanos',
        'padecimiento_actual': 'Padecimiento actual',
      };

      final List<Widget> rows = [];
      ordered.forEach((key, label) {
        final value = d[key] ?? d[key.toLowerCase()] ?? '';
        if (value != null && value.toString().trim().isNotEmpty) {
          if (excludeLower.contains(key.toLowerCase())) return;
          rows.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: LayoutBuilder(builder: (context, constraints) {
                // Si hay suficiente ancho mostrar en fila, si no en columna
                final bool twoColumn = constraints.maxWidth > 380;
                final labelWidget = Text('$label:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: twoColumn ? 16 : 15));
                final valueWidget = Text(value.toString(), style: TextStyle(fontSize: twoColumn ? 16 : 15));
                if (twoColumn) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 160, child: labelWidget),
                      const SizedBox(width: 8),
                      Expanded(child: valueWidget),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelWidget,
                      const SizedBox(height: 4),
                      valueWidget,
                    ],
                  );
                }
              }),
            ),
          );
        }
      });

      if (rows.isEmpty) rows.add(const Text('No hay campos clínicos disponibles.', style: TextStyle(fontSize: 15)));

      // Mostrar diálogo con diseño más atractivo y responsivo (letra más grande)
      showDialog(
        context: context,
        builder: (c) {
          final screenW = MediaQuery.of(c).size.width;
          final titleSize = screenW > 600 ? 20.0 : 18.0;
          final nameSize = screenW > 600 ? 18.0 : 16.0;
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: screenW > 900 ? 700 : 600, maxHeight: MediaQuery.of(c).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0077C2),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_information, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Datos clínicos', style: TextStyle(color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.bold)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(c).pop(),
                        )
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // resumen superior: solo nombre (sin edad)
                          Text(
                            '${d['nombre'] ?? d['Nombre'] ?? ''} ${d['apellido'] ?? d['Apellido'] ?? ''}',
                            style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 18, thickness: 1),
                          ...rows,
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Footer acciones
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(c).pop(),
                            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077C2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Excepción al obtener datos clínicos: $e');
      _showErrorDialog('Error al obtener datos clínicos: $e');
    }
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
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 160),
                            child: ElevatedButton(
                              onPressed: _verDatosClinicos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A2E8),
                                foregroundColor: Colors.white,
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                minimumSize: const Size(140, 44),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.medical_information, size: 18),
                                  SizedBox(width: 10),
                                  Text('Ver datos clínicos', style: TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
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
