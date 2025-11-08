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
  final tipoSangreController = TextEditingController();
  final alergiasController = TextEditingController();
  final enfermedadesController = TextEditingController();
  final medicamentosController = TextEditingController();
  final antecedentesController = TextEditingController();
  final observacionesController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  String? fumador;
  String? consumoAlcohol;
  bool cargando = true;
  Map<String, dynamic> datosOriginales = {};

  @override
  void initState() {
    super.initState();
    obtenerDatosClinicos();
  }

  @override
  void dispose() {
    tipoSangreController.dispose();
    alergiasController.dispose();
    enfermedadesController.dispose();
    medicamentosController.dispose();
    antecedentesController.dispose();
    observacionesController.dispose();
    pesoController.dispose();
    alturaController.dispose();
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

  Future<void> obtenerDatosClinicos() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/doctime/BD/datos_clinicos.php"),
        body: {
          "accion": "obtener",
          "correo": widget.correo,
          "password": widget.password,
          if (widget.clavePaciente != null)
            "clave_paciente": widget.clavePaciente!,
        },
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        final d = data["data"];
        setState(() {
          tipoSangreController.text = d["tipo_sangre"] ?? "";
          alergiasController.text = d["alergias"] ?? "";
          enfermedadesController.text = d["enfermedades_cronicas"] ?? "";
          medicamentosController.text = d["medicamentos_actuales"] ?? "";
          antecedentesController.text = d["antecedentes_medicos"] ?? "";
          observacionesController.text = d["observaciones"] ?? "";
          pesoController.text = d["peso"] ?? "";
          alturaController.text = d["altura"] ?? "";
          fumador = d["fumador"];
          consumoAlcohol = d["consumo_alcohol"];
          datosOriginales = Map<String, dynamic>.from(d);
          cargando = false;
        });
      } else {
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
      _mostrarDialogo(
        titulo: "Error de conexión",
        mensaje: "No se pudieron obtener los datos: $e",
        imagen: "img/Imagen5.png",
        colorTitulo: Colors.red,
      );
    }
  }

  bool _camposObligatoriosLlenos() {
    return tipoSangreController.text.isNotEmpty &&
        alergiasController.text.isNotEmpty &&
        enfermedadesController.text.isNotEmpty;
  }

  bool _seModificoAlgo() {
    return tipoSangreController.text != (datosOriginales["tipo_sangre"] ?? "") ||
        alergiasController.text != (datosOriginales["alergias"] ?? "") ||
        enfermedadesController.text != (datosOriginales["enfermedades_cronicas"] ?? "") ||
        medicamentosController.text != (datosOriginales["medicamentos_actuales"] ?? "") ||
        antecedentesController.text != (datosOriginales["antecedentes_medicos"] ?? "") ||
        observacionesController.text != (datosOriginales["observaciones"] ?? "") ||
        pesoController.text != (datosOriginales["peso"] ?? "") ||
        alturaController.text != (datosOriginales["altura"] ?? "") ||
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
          "tipo_sangre": tipoSangreController.text,
          "alergias": alergiasController.text,
          "enfermedades_cronicas": enfermedadesController.text,
          "medicamentos_actuales": medicamentosController.text,
          "antecedentes_medicos": antecedentesController.text,
          "observaciones": observacionesController.text,
          "peso": pesoController.text,
          "altura": alturaController.text,
          "fumador": fumador ?? "",
          "consumo_alcohol": consumoAlcohol ?? "",
          if (widget.clavePaciente != null)
            "clave_paciente": widget.clavePaciente!,
        },
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        _mostrarDialogo(
          titulo: "Datos guardados",
          mensaje: data["message"] ?? "Se guardaron correctamente.",
          imagen: "img/Imagen4.png",
          colorTitulo: Colors.green,
        );
      } else {
        _mostrarDialogo(
          titulo: "Error al guardar",
          mensaje: data["message"] ?? "No se pudieron guardar los datos.",
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
                          SizedBox(height: 25 * scale),

                          _campo("Tipo de sangre *", tipoSangreController, scale),
                          _campo("Alergias *", alergiasController, scale,
                              maxLines: 2),
                          _campo("Enfermedades crónicas *",
                              enfermedadesController, scale,
                              maxLines: 2),
                          _campo("Medicamentos actuales",
                              medicamentosController, scale,
                              maxLines: 2),
                          _campo("Antecedentes médicos", antecedentesController,
                              scale,
                              maxLines: 2),
                          _campo("Observaciones", observacionesController,
                              scale,
                              maxLines: 2),
                          _campo("Peso (kg) - opcional", pesoController, scale,
                              keyboardType: TextInputType.number),
                          _campo("Altura (m) - opcional", alturaController, scale,
                              keyboardType: TextInputType.number),

                          SizedBox(height: 25 * scale),

                          // 🔹 Botón Guardar
                          SizedBox(
                            width: constraints.maxWidth > 600
                                ? 220 * scale
                                : double.infinity,
                            child: ElevatedButton(
                              onPressed: guardarDatosClinicos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077C2),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10 * scale),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Volver',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
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
