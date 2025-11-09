import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final alergiasController = TextEditingController();
  final enfermedadesController = TextEditingController();
  final medicamentosController = TextEditingController();
  final antecedentesController = TextEditingController();
  final observacionesController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  // Antecedentes personales patológicos (detalle)
  final diabetesController = TextEditingController(); // "Sí/No/Desde cuándo"
  final hipertensionController = TextEditingController(); // "Sí/No/Desde cuándo"
  final cirugiasController = TextEditingController(); // cirugías previas y fechas
  // Antecedentes no patológicos
  final tabaquismoController = TextEditingController(); // "Sí/No, cuánto y por cuánto tiempo"
  final alcoholismoController = TextEditingController(); // "Sí/No, frecuencia y cantidad"
  final alimentacionController = TextEditingController(); // tipo de dieta, comidas
  final ejercicioController = TextEditingController(); // tipo, frecuencia, duración

  // Heredofamiliares
  final padreController = TextEditingController();
  final madreController = TextEditingController();
  final hermanosController = TextEditingController();

  // Padecimiento actual
  final padecimientoActualController = TextEditingController();

  String? fumador;
  String? consumoAlcohol;
  bool cargando = true;
  Map<String, dynamic> datosOriginales = {};

  @override
  void initState() {
    super.initState();
    obtenerDatosClinicos();
  }

  Future<void> obtenerDatosClinicos() async {
    setState(() { cargando = true; });
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
        // respuesta inválida
        setState(() { datosOriginales = {}; cargando = false; });
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
          alergiasController.text = d["alergias"] ?? '';
          enfermedadesController.text = d["enfermedades_cronicas"] ?? '';
          medicamentosController.text = d["medicamentos_actuales"] ?? '';
          antecedentesController.text = d["antecedentes_medicos"] ?? '';
          observacionesController.text = d["observaciones"] ?? '';
          pesoController.text = (d["peso"] ?? '').toString();
          alturaController.text = (d["altura"] ?? '').toString();
          diabetesController.text = d["diabetes"] ?? '';
          hipertensionController.text = d["hipertension"] ?? '';
          cirugiasController.text = d["cirugias_previas"] ?? '';
          tabaquismoController.text = d["tabaquismo"] ?? '';
          alcoholismoController.text = d["alcoholismo"] ?? '';
          alimentacionController.text = d["alimentacion"] ?? '';
          ejercicioController.text = d["ejercicio"] ?? '';
          padreController.text = d["padre"] ?? '';
          madreController.text = d["madre"] ?? '';
          hermanosController.text = d["hermanos"] ?? '';
          padecimientoActualController.text = d["padecimiento_actual"] ?? '';
          fumador = d["fumador"]?.toString() ?? '';
          consumoAlcohol = d["consumo_alcohol"]?.toString() ?? '';
          datosOriginales = Map<String, dynamic>.from(d);
          cargando = false;
        });
      } else {
        // no hay datos: controllers quedan vacíos y guardamos defaults
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
    diabetesController.dispose();
    hipertensionController.dispose();
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
        alergiasController.text.isNotEmpty &&
        enfermedadesController.text.isNotEmpty;
  }

  bool _seModificoAlgo() {
    // compara los campos nuevos con los datos originales
    return nombreController.text != (datosOriginales["nombre"] ?? "") ||
        edadController.text != (datosOriginales["edad"]?.toString() ?? "") ||
        sexoController.text != (datosOriginales["sexo"] ?? "") ||
        fechaNacimientoController.text != (datosOriginales["fecha_nacimiento"] ?? "") ||
        curpController.text != (datosOriginales["curp"] ?? "") ||
        telefonoController.text != (datosOriginales["telefono"] ?? "") ||
        direccionController.text != (datosOriginales["direccion"] ?? "") ||
        tipoSangreController.text != (datosOriginales["tipo_sangre"] ?? "") ||
        alergiasController.text != (datosOriginales["alergias"] ?? "") ||
        enfermedadesController.text != (datosOriginales["enfermedades_cronicas"] ?? "") ||
        medicamentosController.text != (datosOriginales["medicamentos_actuales"] ?? "") ||
        antecedentesController.text != (datosOriginales["antecedentes_medicos"] ?? "") ||
        observacionesController.text != (datosOriginales["observaciones"] ?? "") ||
        pesoController.text != (datosOriginales["peso"] ?? "") ||
        alturaController.text != (datosOriginales["altura"] ?? "") ||
        diabetesController.text != (datosOriginales["diabetes"] ?? "") ||
        hipertensionController.text != (datosOriginales["hipertension"] ?? "") ||
        cirugiasController.text != (datosOriginales["cirugias_previas"] ?? "") ||
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
            "Completa los campos obligatorios: Tipo de sangre, Alergias y Enfermedades crónicas.",
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
          "alergias": alergiasController.text,
          "enfermedades_cronicas": enfermedadesController.text,
          "medicamentos_actuales": medicamentosController.text,
          "antecedentes_medicos": antecedentesController.text,
          "observaciones": observacionesController.text,
          "peso": pesoController.text,
          "altura": alturaController.text,

          // Patológicos
          "diabetes": diabetesController.text,
          "hipertension": hipertensionController.text,
          "cirugias_previas": cirugiasController.text,

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

      // debug: imprimir status y body
      print('guardarDatosClinicos HTTP ${response.statusCode}: ${response.body}');

      // proteger contra body no-JSON
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
        // si el endpoint devuelve "data", usarlo para rellenar inmediatamente
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
            alergiasController.text = d["alergias"] ?? "";
            enfermedadesController.text = d["enfermedades_cronicas"] ?? "";
            medicamentosController.text = d["medicamentos_actuales"] ?? "";
            antecedentesController.text = d["antecedentes_medicos"] ?? "";
            observacionesController.text = d["observaciones"] ?? "";
            pesoController.text = d["peso"]?.toString() ?? "";
            alturaController.text = d["altura"]?.toString() ?? "";

            diabetesController.text = d["diabetes"] ?? "";
            hipertensionController.text = d["hipertension"] ?? "";
            cirugiasController.text = d["cirugias_previas"] ?? "";

            tabaquismoController.text = d["tabaquismo"] ?? "";
            alcoholismoController.text = d["alcoholismo"] ?? "";
            alimentacionController.text = d["alimentacion"] ?? "";
            ejercicioController.text = d["ejercicio"] ?? "";

            padreController.text = d["padre"] ?? "";
            madreController.text = d["madre"] ?? "";
            hermanosController.text = d["hermanos"] ?? "";

            padecimientoActualController.text = d["padecimiento_actual"] ?? "";

            fumador = d["fumador"] ?? "";
            consumoAlcohol = d["consumo_alcohol"] ?? "";
            datosOriginales = Map<String, dynamic>.from(d);
          });
        } else {
          // adicional: refrescar desde el endpoint obtenerDatosClinicos
          await obtenerDatosClinicos();
        }

        _mostrarDialogo(
          titulo: "Datos guardados",
          mensaje: data["message"] ?? "Se guardaron correctamente.",
          imagen: "img/Imagen4.png",
          colorTitulo: Colors.green,
        );
      } else {
        // mostrar mensaje de error con detalle si existe
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
                                  Container(
                                    width: 50 * scale,
                                    height: 50 * scale,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage("img/logo.png"),
                                        fit: BoxFit.contain,
                                      ),
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
                                child: Container(
                                  width: 50 * scale,
                                  height: 50 * scale,
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
                          _campo("Edad", edadController, scale,
                              keyboardType: TextInputType.number),
                          _campo("Sexo", sexoController, scale),
                          _campo("Fecha de nacimiento", fechaNacimientoController, scale),
                          _campo("CURP", curpController, scale),
                          _campo("Teléfono", telefonoController, scale,
                              keyboardType: TextInputType.phone),
                          _campo("Dirección", direccionController, scale, maxLines: 2),

                          SizedBox(height: 12 * scale),

                          // Sección: Antecedentes personales patológicos
                          _seccionTitle("3. Antecedentes Personales Patológicos", scale),
                          _campo("Diabetes (Sí/No/Desde cuándo)", diabetesController, scale),
                          _campo("Hipertensión (Sí/No/Desde cuándo)", hipertensionController, scale),
                          _campo("Alergias (medicamentosas, alimentarias, ambientales) *", alergiasController, scale, maxLines: 2),
                          _campo("Cirugías previas (cuáles y fechas aproximadas)", cirugiasController, scale, maxLines: 2),
                          _campo("Medicamentos actuales (nombre, dosis, frecuencia)", medicamentosController, scale, maxLines: 2),

                          SizedBox(height: 12 * scale),

                          // Sección: Antecedentes no patológicos
                          _seccionTitle("4. Antecedentes no patológicos", scale),
                          _campo("Tabaquismo (Sí/No, cuánto y por cuánto tiempo)", tabaquismoController, scale),
                          _campo("Alcoholismo (Sí/No, frecuencia y cantidad)", alcoholismoController, scale),
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
                          _campo("Tipo de sangre *", tipoSangreController, scale),
                          _campo("Enfermedades crónicas *", enfermedadesController, scale, maxLines: 2),
                          _campo("Antecedentes médicos", antecedentesController, scale, maxLines: 2),
                          _campo("Observaciones", observacionesController, scale, maxLines: 2),
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
