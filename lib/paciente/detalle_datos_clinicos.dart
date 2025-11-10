import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'patient_dialog.dart';

class DetalleDatosClinicosPage extends StatefulWidget {
  final String correo;
  final String password;
  final String? clavePaciente;

  const DetalleDatosClinicosPage({
    Key? key,
    required this.correo,
    required this.password,
    this.clavePaciente,
  }) : super(key: key);

  @override
  State<DetalleDatosClinicosPage> createState() =>
      _DetalleDatosClinicosPageState();
}

class _DetalleDatosClinicosPageState extends State<DetalleDatosClinicosPage> {
  // Identificación
  final nombreController = TextEditingController();
  final edadController = TextEditingController();
  final sexoController = TextEditingController();
  final fechaNacimientoController = TextEditingController();
  final curpController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();

  // Datos clínicos / antecedentes
  final tipoSangreController = TextEditingController();
  // alergias ahora: selector + detalle
  final alergiasController = TextEditingController();
  String? alergiasSiNo;

  final enfermedadesController = TextEditingController();
  // medicamentos: selector + detalle
  final medicamentosController = TextEditingController();
  String? medicamentosSiNo;

  final antecedentesController = TextEditingController();
  final observacionesController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  // Antecedentes personales patológicos (detalle)
  String? diabetesSiNo;
  final diabetesDesdeController = TextEditingController(); // detalle "desde cuándo"
  String? hipertensionSiNo;
  final hipertensionDesdeController = TextEditingController();

  final cirugiasController = TextEditingController(); // detalle
  String? cirugiasSiNo;

  // Antecedentes no patológicos
  final tabaquismoController = TextEditingController(); // detalle tabaquismo
  String? fumador;
  final alcoholismoController = TextEditingController(); // detalle alcohol
  String? consumoAlcohol;
  final alimentacionController = TextEditingController(); // tipo de dieta, comidas
  final ejercicioController = TextEditingController(); // tipo, frecuencia, duración

  // Heredofamiliares
  final padreController = TextEditingController();
  final madreController = TextEditingController();
  final hermanosController = TextEditingController();

  // Padecimiento actual
  final padecimientoActualController = TextEditingController();

  bool cargando = true;
  Map<String, dynamic> datosOriginales = {};

  @override
  void initState() {
    super.initState();
    obtenerDatosClinicos();
  }

  // Normaliza valores de sí/no (acepta 1/0, "si","sí","no", true/false, etc.)
  String? _normalizeSiNo(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim().toLowerCase();
    if (s == '' || s == 'null') return null;
    if (s == '1' || s == 'si' || s == 'sí' || s == 's' || s == 'true') return 'Sí';
    if (s == '0' || s == 'no' || s == 'n' || s == 'false') return 'No';
    if (s == 'sí' || s == 'si') return 'Sí';
    if (s == 'no') return 'No';
    return v.toString();
  }

  // Evita crash cuando el valor actual no está en la lista de opciones
  String? _safeDropdownValue(String? val, List<String> opciones) {
    if (val == null) return null;
    return opciones.contains(val) ? val : null;
  }

  // Parsea campos que vienen como "Sí - desde 2010" o "No" o "Desde 2010"
  Map<String, String?> _splitSiDetalle(dynamic v) {
    if (v == null) return {'siNo': null, 'detalle': ''};
    final s = v.toString().trim();
    final lower = s.toLowerCase();
    String? siNo;
    String detalle = '';
    if (lower.startsWith('sí') || lower.startsWith('si') || lower.startsWith('sí') || lower.startsWith('si ')) {
      siNo = 'Sí';
      // después de primer '-' o ':' o 'desde'
      final idx = s.indexOf('-');
      if (idx >= 0 && idx + 1 < s.length) {
        detalle = s.substring(idx + 1).trim();
      } else {
        // buscar 'desde'
        final desdeIndex = lower.indexOf('desde');
        if (desdeIndex >= 0) detalle = s.substring(desdeIndex).trim();
      }
    } else if (lower.startsWith('no')) {
      siNo = 'No';
      // detalle vacio
    } else if (lower.contains('desde')) {
      siNo = 'Sí';
      detalle = s;
    } else {
      // fallback: dejar todo como detalle
      detalle = s;
    }
    return {'siNo': siNo, 'detalle': detalle};
  }

  Future<void> obtenerDatosClinicos() async {
    setState(() {
      cargando = true;
    });
    try {
      final uri = Uri.parse("http://localhost/doctime/BD/obtenerDatosClinicos.php");
      final response = await http.post(uri, body: {
        "correo": widget.correo,
        "password": widget.password,
        if (widget.clavePaciente != null) "clave_paciente": widget.clavePaciente!,
      });

      final body = response.body?.trim() ?? '';
      print('obtenerDatosClinicos HTTP ${response.statusCode}: $body');

      if (!body.startsWith('{')) {
        setState(() {
          datosOriginales = {};
          cargando = false;
        });
        return;
      }

      final json = jsonDecode(body);
      if (json["success"] == true && json["data"] != null) {
        final d = json["data"];
        setState(() {
          nombreController.text = d["nombre"] ?? '';
          edadController.text = (d["edad"] ?? '').toString();
          sexoController.text = d["sexo"] ?? '';
          fechaNacimientoController.text = d["fecha_nacimiento"] ?? '';
          curpController.text = d["curp"] ?? '';
          telefonoController.text = d["telefono"] ?? '';
          direccionController.text = d["direccion"] ?? '';
          tipoSangreController.text = d["tipo_sangre"] ?? '';

          // Alergias: parsear si/no + detalle
          final parsedAler = _splitSiDetalle(d["alergias"]);
          alergiasSiNo = parsedAler['siNo'];
          alergiasController.text = parsedAler['detalle'] ?? '';

          enfermedadesController.text = d["enfermedades_cronicas"] ?? '';

          // Medicamentos: parsear si/no + detalle
          final parsedMed = _splitSiDetalle(d["medicamentos_actuales"]);
          medicamentosSiNo = parsedMed['siNo'];
          medicamentosController.text = parsedMed['detalle'] ?? '';

          antecedentesController.text = d["antecedentes_medicos"] ?? '';
          observacionesController.text = d["observaciones"] ?? '';
          pesoController.text = (d["peso"] ?? '').toString();
          alturaController.text = (d["altura"] ?? '').toString();

          // Diabetes
          final parsedDiab = _splitSiDetalle(d["diabetes"]);
          diabetesSiNo = parsedDiab['siNo'];
          diabetesDesdeController.text = parsedDiab['detalle'] ?? '';

          // Hipertensión
          final parsedHip = _splitSiDetalle(d["hipertension"]);
          hipertensionSiNo = parsedHip['siNo'];
          hipertensionDesdeController.text = parsedHip['detalle'] ?? '';

          // Cirugías
          final parsedCir = _splitSiDetalle(d["cirugias_previas"]);
          cirugiasSiNo = parsedCir['siNo'];
          cirugiasController.text = parsedCir['detalle'] ?? '';

          // Tabaquismo y alcohol
          tabaquismoController.text = d["tabaquismo"] ?? '';
          alcoholismoController.text = d["alcoholismo"] ?? '';
          fumador = _normalizeSiNo(d["fumador"]);
          consumoAlcohol = _normalizeSiNo(d["consumo_alcohol"]);

          alimentacionController.text = d["alimentacion"] ?? '';
          ejercicioController.text = d["ejercicio"] ?? '';

          padreController.text = d["padre"] ?? '';
          madreController.text = d["madre"] ?? '';
          hermanosController.text = d["hermanos"] ?? '';
          padecimientoActualController.text = d["padecimiento_actual"] ?? '';

          // Guardar originales (manteniendo los formatos originales)
          datosOriginales = Map<String, dynamic>.from(d);
          // normalizar para comparaciones
          datosOriginales["fumador"] = fumador;
          datosOriginales["consumo_alcohol"] = consumoAlcohol;
          cargando = false;
        });
      } else {
        setState(() {
          datosOriginales = {};
          cargando = false;
        });
      }
    } catch (e) {
      print('error obtenerDatosClinicos: $e');
      setState(() {
        datosOriginales = {};
        cargando = false;
      });
    }
  }

  @override
  void dispose() {
    // Identificación
    nombreController.dispose();
    edadController.dispose();
    sexoController.dispose();
    fechaNacimientoController.dispose();
    curpController.dispose();
    telefonoController.dispose();
    direccionController.dispose();

    // Datos clínicos
    tipoSangreController.dispose();
    alergiasController.dispose();
    enfermedadesController.dispose();
    medicamentosController.dispose();
    antecedentesController.dispose();
    observacionesController.dispose();
    pesoController.dispose();
    alturaController.dispose();

    // Patológicos / no patológicos
    diabetesDesdeController.dispose();
    hipertensionDesdeController.dispose();
    cirugiasController.dispose();
    tabaquismoController.dispose();
    alcoholismoController.dispose();
    alimentacionController.dispose();
    ejercicioController.dispose();

    // Heredofamiliares
    padreController.dispose();
    madreController.dispose();
    hermanosController.dispose();

    // Padecimiento actual
    padecimientoActualController.dispose();

    super.dispose();
  }

  // Combina selector Sí/No + detalle en una cadena para enviar/ comparar
  String _combineSiDetalle(String? siNo, TextEditingController detalleController) {
    final d = detalleController.text.trim();
    if (siNo == null) {
      return d;
    }
    if (siNo == 'Sí') {
      return d.isEmpty ? 'Sí' : 'Sí - $d';
    } else {
      return 'No';
    }
  }

  // 🔹 Nuevo diseño de alerta uniforme
  void _mostrarDialogo({
    required String titulo,
    required String mensaje,
    required String imagen,
    Color colorTitulo = Colors.black,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagen,
                height: 100,
                width: 100,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: colorTitulo,
                ),
              ),
            ],
          ),
        ),
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Aceptar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0077C2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _camposObligatoriosLlenos() {
    return tipoSangreController.text.isNotEmpty &&
        (alergiasSiNo == 'Sí' ? alergiasController.text.isNotEmpty : true) &&
        enfermedadesController.text.isNotEmpty;
  }

  bool _seModificoAlgo() {
    // compara los campos nuevos con los datos originales (usando las combinaciones)
    final currDiabetes = _combineSiDetalle(diabetesSiNo, diabetesDesdeController);
    final currHip = _combineSiDetalle(hipertensionSiNo, hipertensionDesdeController);
    final currAlergias = alergiasSiNo == null ? alergiasController.text : (alergiasSiNo == 'Sí' ? 'Sí - ${alergiasController.text.trim()}' : 'No');
    final currMedic = medicamentosSiNo == null ? medicamentosController.text : (medicamentosSiNo == 'Sí' ? 'Sí - ${medicamentosController.text.trim()}' : 'No');
    final currCirugias = cirugiasSiNo == null ? cirugiasController.text : (cirugiasSiNo == 'Sí' ? 'Sí - ${cirugiasController.text.trim()}' : 'No');

    return nombreController.text != (datosOriginales["nombre"] ?? "") ||
        edadController.text != (datosOriginales["edad"]?.toString() ?? "") ||
        sexoController.text != (datosOriginales["sexo"] ?? "") ||
        fechaNacimientoController.text != (datosOriginales["fecha_nacimiento"] ?? "") ||
        curpController.text != (datosOriginales["curp"] ?? "") ||
        telefonoController.text != (datosOriginales["telefono"] ?? "") ||
        direccionController.text != (datosOriginales["direccion"] ?? "") ||
        tipoSangreController.text != (datosOriginales["tipo_sangre"] ?? "") ||
        currAlergias != (datosOriginales["alergias"] ?? "") ||
        enfermedadesController.text != (datosOriginales["enfermedades_cronicas"] ?? "") ||
        currMedic != (datosOriginales["medicamentos_actuales"] ?? "") ||
        antecedentesController.text != (datosOriginales["antecedentes_medicos"] ?? "") ||
        observacionesController.text != (datosOriginales["observaciones"] ?? "") ||
        pesoController.text != (datosOriginales["peso"] ?? "") ||
        alturaController.text != (datosOriginales["altura"] ?? "") ||
        currDiabetes != (datosOriginales["diabetes"] ?? "") ||
        currHip != (datosOriginales["hipertension"] ?? "") ||
        currCirugias != (datosOriginales["cirugias_previas"] ?? "") ||
        tabaquismoController.text != (datosOriginales["tabaquismo"] ?? "") ||
        alcoholismoController.text != (datosOriginales["alcoholismo"] ?? "") ||
        alimentacionController.text != (datosOriginales["alimentacion"] ?? "") ||
        ejercicioController.text != (datosOriginales["ejercicio"] ?? "") ||
        padreController.text != (datosOriginales["padre"] ?? "") ||
        madreController.text != (datosOriginales["madre"] ?? "") ||
        hermanosController.text != (datosOriginales["hermanos"] ?? "") ||
        padecimientoActualController.text != (datosOriginales["padecimiento_actual"] ?? "") ||
        fumador != (datosOriginales["fumador"]) ||
        consumoAlcohol != (datosOriginales["consumo_alcohol"]);
  }

  Future<void> guardarDatosClinicos() async {
    if (!_camposObligatoriosLlenos()) {
      _mostrarDialogo(
        titulo: "Campos obligatorios",
        mensaje:
            "Completa los campos obligatorios: Tipo de sangre, Alergias (si aplica) y Enfermedades crónicas.",
        imagen: "img/Imagen5.png",
        colorTitulo: Colors.red,
      );
      return;
    }

    if (!_seModificoAlgo()) {
      _mostrarDialogo(
        titulo: "Sin cambios",
        mensaje: "No se detectaron modificaciones para guardar.",
        imagen: "img/Imagen5.png",
        colorTitulo: Colors.red,
      );
      return;
    }

    try {
      // preparar valores combinados para enviar
      final diabetesEnviar = _combineSiDetalle(diabetesSiNo, diabetesDesdeController);
      final hipertensionEnviar = _combineSiDetalle(hipertensionSiNo, hipertensionDesdeController);
      final alergiasEnviar = alergiasSiNo == null ? alergiasController.text.trim() : (alergiasSiNo == 'Sí' ? 'Sí - ${alergiasController.text.trim()}' : 'No');
      final medicamentosEnviar = medicamentosSiNo == null ? medicamentosController.text.trim() : (medicamentosSiNo == 'Sí' ? 'Sí - ${medicamentosController.text.trim()}' : 'No');
      final cirugiasEnviar = cirugiasSiNo == null ? cirugiasController.text.trim() : (cirugiasSiNo == 'Sí' ? 'Sí - ${cirugiasController.text.trim()}' : 'No');

      final response = await http.post(
        Uri.parse("http://localhost/doctime/BD/datos_clinicos.php"),
        body: {
          "accion": "guardar",
          "correo": widget.correo,
          "password": widget.password,

          // Identificación
          "nombre": nombreController.text,
          "edad": edadController.text,
          "sexo": sexoController.text,
          "fecha_nacimiento": fechaNacimientoController.text,
          "curp": curpController.text,
          "telefono": telefonoController.text,
          "direccion": direccionController.text,

          // Clínicos / antecedentes
          "tipo_sangre": tipoSangreController.text,
          "alergias": alergiasEnviar,
          "enfermedades_cronicas": enfermedadesController.text,
          "medicamentos_actuales": medicamentosEnviar,
          "antecedentes_medicos": antecedentesController.text,
          "observaciones": observacionesController.text,
          "peso": pesoController.text,
          "altura": alturaController.text,

          // Patológicos
          "diabetes": diabetesEnviar,
          "hipertension": hipertensionEnviar,
          "cirugias_previas": cirugiasEnviar,

          // No patológicos
          "tabaquismo": tabaquismoController.text,
          "alcoholismo": alcoholismoController.text,
          "alimentacion": alimentacionController.text,
          "ejercicio": ejercicioController.text,

          // Heredofamiliares
          "padre": padreController.text,
          "madre": madreController.text,
          "hermanos": hermanosController.text,

          // Padecimiento actual
          "padecimiento_actual": padecimientoActualController.text,

          "fumador": fumador ?? "",
          "consumo_alcohol": consumoAlcohol ?? "",
          if (widget.clavePaciente != null) "clave_paciente": widget.clavePaciente!,
        },
      );

      print('guardarDatosClinicos HTTP ${response.statusCode}: ${response.body}');

      final body = response.body?.trim() ?? '';
      if (!body.startsWith('{') && !body.startsWith('[')) {
        _mostrarDialogo(
          titulo: "Respuesta inválida",
          mensaje: "Respuesta del servidor no es JSON:\n$body",
          imagen: "img/Imagen5.png",
          colorTitulo: Colors.red,
        );
        return;
      }

      final data = jsonDecode(body);
      if (response.statusCode != 200) {
        _mostrarDialogo(
          titulo: "Error de servidor",
          mensaje: "HTTP ${response.statusCode}",
          imagen: "img/Imagen5.png",
          colorTitulo: Colors.red,
        );
        return;
      }

      if (data["success"] == true) {
        if (data["data"] != null) {
          final d = data["data"];
          setState(() {
            nombreController.text = d["nombre"] ?? "";
            edadController.text = d["edad"]?.toString() ?? "";
            sexoController.text = d["sexo"] ?? "";
            fechaNacimientoController.text = d["fecha_nacimiento"] ?? "";
            curpController.text = d["curp"] ?? "";
            telefonoController.text = d["telefono"] ?? "";
            direccionController.text = d["direccion"] ?? "";

            tipoSangreController.text = d["tipo_sangre"] ?? "";

            // reparsear lo guardado
            final parsedAler = _splitSiDetalle(d["alergias"]);
            alergiasSiNo = parsedAler['siNo'];
            alergiasController.text = parsedAler['detalle'] ?? '';

            enfermedadesController.text = d["enfermedades_cronicas"] ?? "";

            final parsedMed = _splitSiDetalle(d["medicamentos_actuales"]);
            medicamentosSiNo = parsedMed['siNo'];
            medicamentosController.text = parsedMed['detalle'] ?? '';

            antecedentesController.text = d["antecedentes_medicos"] ?? "";
            observacionesController.text = d["observaciones"] ?? "";
            pesoController.text = d["peso"]?.toString() ?? "";
            alturaController.text = d["altura"]?.toString() ?? "";

            final parsedDiab = _splitSiDetalle(d["diabetes"]);
            diabetesSiNo = parsedDiab['siNo'];
            diabetesDesdeController.text = parsedDiab['detalle'] ?? '';

            final parsedHip = _splitSiDetalle(d["hipertension"]);
            hipertensionSiNo = parsedHip['siNo'];
            hipertensionDesdeController.text = parsedHip['detalle'] ?? '';

            final parsedCir = _splitSiDetalle(d["cirugias_previas"]);
            cirugiasSiNo = parsedCir['siNo'];
            cirugiasController.text = parsedCir['detalle'] ?? '';

            tabaquismoController.text = d["tabaquismo"] ?? "";
            alcoholismoController.text = d["alcoholismo"] ?? "";
            fumador = _normalizeSiNo(d["fumador"]);
            consumoAlcohol = _normalizeSiNo(d["consumo_alcohol"]);

            alimentacionController.text = d["alimentacion"] ?? "";
            ejercicioController.text = d["ejercicio"] ?? "";

            padreController.text = d["padre"] ?? "";
            madreController.text = d["madre"] ?? "";
            hermanosController.text = d["hermanos"] ?? "";

            padecimientoActualController.text = d["padecimiento_actual"] ?? "";

            datosOriginales = Map<String, dynamic>.from(d);
            datosOriginales["fumador"] = fumador;
            datosOriginales["consumo_alcohol"] = consumoAlcohol;
          });
        } else {
          await obtenerDatosClinicos();
        }

        _mostrarDialogo(
          titulo: "Datos guardados",
          mensaje: data["message"] ?? "Se guardaron correctamente.",
          imagen: "img/Imagen4.png",
          colorTitulo: Colors.green,
        );
      } else {
        final errDetalle = data["error_stmt"] ?? data["error_conn"] ?? data["message"] ?? response.body;
        _mostrarDialogo(
          titulo: "Error al guardar",
          mensaje: errDetalle.toString(),
          imagen: "img/Imagen5.png",
          colorTitulo: Colors.red,
        );
      }
    } catch (e) {
      _mostrarDialogo(
        titulo: "Error de conexión",
        mensaje: "Ocurrió un error: $e",
        imagen: "img/Imagen5.png",
        colorTitulo: Colors.red,
      );
    }
  }

  Widget _seccionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0077C2),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFechaNacimiento(BuildContext context) async {
    DateTime initial = DateTime.now();
    try {
      if (fechaNacimientoController.text.isNotEmpty) {
        final parts = fechaNacimientoController.text.split(RegExp(r'[-/]'));
        if (parts.length >= 3) {
          final d = int.tryParse(parts[0]) ?? int.tryParse(parts.last) ?? initial.day;
          final m = int.tryParse(parts[1]) ?? initial.month;
          final y = int.tryParse(parts[2]) ?? initial.year;
          initial = DateTime(y, m, d);
        }
      }
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fechaNacimientoController.text = "${picked.day.toString().padLeft(2,'0')}/${picked.month.toString().padLeft(2,'0')}/${picked.year}";
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double scale = constraints.maxWidth / 400;
        scale = scale.clamp(0.8, 1.2);

        return Scaffold(
          backgroundColor: Colors.white,
          body: cargando
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(16 * scale),
                      child: Column(
                        children: [
                          SizedBox(height: 10 * scale),

                          // 🔹 Encabezado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 50 * scale,
                                    height: 50 * scale,
                                    child: Image.asset(
                                      "img/logo.png",
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 50 * scale, color: Colors.grey),
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DocTime',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15 * scale,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Consultas y citas médicas',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 11 * scale,
                                          fontWeight: FontWeight.w500,
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
                                child: SizedBox(
                                  width: 50 * scale,
                                  height: 50 * scale,
                                  child: Image.asset(
                                    "img/Imagen2.png",
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, size: 50 * scale, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 25 * scale),
                          Text(
                            'Datos Clínicos del Paciente',
                            style: TextStyle(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0077C2),
                            ),
                          ),
                          SizedBox(height: 20 * scale),

                          // Sección 1: Identificación
                          _seccionTitle("1. Datos de Identificación", scale),
                          _campo("Nombre del paciente", nombreController, scale),

                          // Edad: solo números
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: TextFormField(
                              controller: edadController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Edad',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                            ),
                          ),

                          // SEXO: Dropdown seguro (value null si vacío)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: DropdownButtonFormField<String>(
                              value: _safeDropdownValue(sexoController.text, [
                                'Masculino',
                                'Femenino',
                                'Otro',
                                'Prefiero no decir'
                              ]),
                              items: [
                                'Masculino',
                                'Femenino',
                                'Otro',
                                'Prefiero no decir'
                              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  sexoController.text = v ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Sexo',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                            ),
                          ),

                          // Fecha de nacimiento: campo de texto normal
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: TextFormField(
                              controller: fechaNacimientoController,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: 'Fecha de nacimiento (DD/MM/YYYY)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                            ),
                          ),

                          _campo("CURP", curpController, scale),

                          // Teléfono: solo números
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: TextFormField(
                              controller: telefonoController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: 'Teléfono',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                            ),
                          ),

                          _campo("Dirección", direccionController, scale, maxLines: 2),

                          SizedBox(height: 12 * scale),

                          // Sección: Antecedentes personales patológicos
                          _seccionTitle("3. Antecedentes Personales Patológicos", scale),

                          // Diabetes: selector + desde cuándo
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(diabetesSiNo, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      diabetesSiNo = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Diabetes (Sí/No)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: diabetesDesdeController,
                                  maxLines: 1,
                                  enabled: diabetesSiNo == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Desde cuándo (ej. 2015, 01/2015, tratamiento)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Hipertensión: selector + desde cuándo
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(hipertensionSiNo, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      hipertensionSiNo = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Hipertensión (Sí/No)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: hipertensionDesdeController,
                                  maxLines: 1,
                                  enabled: hipertensionSiNo == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Desde cuándo (ej. año / tratamiento)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Alergias: selector + detalle
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(alergiasSiNo, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      alergiasSiNo = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: '¿Tiene alergias?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: alergiasController,
                                  maxLines: 2,
                                  enabled: alergiasSiNo == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Detalle alergias (medicamentos, alimentos, etc.)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cirugías: selector + detalle
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(cirugiasSiNo, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      cirugiasSiNo = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: '¿Cirugías previas?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: cirugiasController,
                                  maxLines: 2,
                                  enabled: cirugiasSiNo == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Detalle cirugías (cuáles y fechas)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Medicamentos actuales: selector + detalle
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(medicamentosSiNo, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      medicamentosSiNo = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: '¿Toma medicamentos actualmente?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: medicamentosController,
                                  maxLines: 2,
                                  enabled: medicamentosSiNo == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Detalle medicamentos (nombre, dosis, frecuencia)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12 * scale),

                          // Sección: Antecedentes no patológicos
                          _seccionTitle("4. Antecedentes no patológicos", scale),

                          // FUMADOR: selector Sí/No + detalle habilitado sólo si es "Sí"
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(fumador, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      fumador = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: '¿Es fumador?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: tabaquismoController,
                                  maxLines: 1,
                                  enabled: fumador == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Detalle tabaquismo (cantidad / tiempo)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ALCOHOL: selector Sí/No + detalle habilitado sólo si es "Sí"
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _safeDropdownValue(consumoAlcohol, ['Sí', 'No']),
                                  items: ['Sí', 'No'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      consumoAlcohol = v;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: '¿Consume alcohol?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                TextFormField(
                                  controller: alcoholismoController,
                                  maxLines: 1,
                                  enabled: consumoAlcohol == 'Sí',
                                  decoration: InputDecoration(
                                    labelText: 'Detalle consumo de alcohol (frecuencia / cantidad)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _campo("Alimentación (tipo de dieta, número de comidas)", alimentacionController, scale),
                          _campo("Ejercicio (tipo, frecuencia y duración)", ejercicioController, scale),

                          SizedBox(height: 12 * scale),

                          // Sección: Heredofamiliares
                          _seccionTitle("5. Antecedentes Heredofamiliares", scale),
                          _campo("Padre (enfermedades importantes)", padreController, scale),
                          _campo("Madre (enfermedades importantes)", madreController, scale),
                          _campo("Hermanos (enfermedades importantes)", hermanosController, scale),

                          SizedBox(height: 12 * scale),

                          // Sección: Padecimiento actual
                          _seccionTitle("6. Padecimiento Actual", scale),
                          _campo("Padecimiento actual (descripción detallada)", padecimientoActualController, scale, maxLines: 3),

                          SizedBox(height: 12 * scale),

                          // Otros datos clínicos y observaciones
                          _seccionTitle("Otros datos clínicos", scale),

                          // TIPO DE SANGRE: dropdown
                          Padding(
                            padding: EdgeInsets.only(bottom: 12 * scale),
                            child: DropdownButtonFormField<String>(
                              value: _safeDropdownValue(tipoSangreController.text, [
                                'A+','A-','B+','B-','AB+','AB-','O+','O-','Desconocido'
                              ]),
                              items: [
                                'A+','A-','B+','B-','AB+','AB-','O+','O-','Desconocido'
                              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) {
                                setState(() {
                                  tipoSangreController.text = v ?? '';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Tipo de sangre *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                            ),
                          ),

                          _campo("Enfermedades crónicas *", enfermedadesController, scale, maxLines: 2),
                          _campo("Antecedentes médicos", antecedentesController, scale, maxLines: 2),
                          _campo("Observaciones", observacionesController, scale, maxLines: 2),

                          // Peso / Altura
                          _campo("Peso (kg) - opcional", pesoController, scale, keyboardType: TextInputType.number),
                          _campo("Altura (m) - opcional", alturaController, scale, keyboardType: TextInputType.number),

                          SizedBox(height: 25 * scale),

                          // 🔹 Botón Guardar
                          SizedBox(
                            width: constraints.maxWidth > 600 ? 220 * scale : double.infinity,
                            child: ElevatedButton(
                              onPressed: guardarDatosClinicos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077C2),
                                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                              ),
                              child: Text(
                                "Guardar",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 80 * scale),
                        ],
                      ),
                    ),

                    // 🔹 Botón Volver centrado abajo
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: constraints.maxWidth > 600 ? 180 : 140,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077C2),
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
      },
    );
  }

  Widget _campo(String label, TextEditingController controller, double scale,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10 * scale),
          ),
        ),
      ),
    );
  }
}
