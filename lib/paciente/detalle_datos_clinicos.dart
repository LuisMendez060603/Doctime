import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'patient_dialog.dart';

class DetalleDatosClinicosPage extends StatefulWidget {
  final String correo;
  final String password;
  final String? clavePaciente; // opcional

  const DetalleDatosClinicosPage({
    Key? key,
    required this.correo,
    required this.password,
    this.clavePaciente,
  }) : super(key: key);

  @override
  State<DetalleDatosClinicosPage> createState() => _DetalleDatosClinicosPageState();
}

class _DetalleDatosClinicosPageState extends State<DetalleDatosClinicosPage> {
  final _formKey = GlobalKey<FormState>();

  // 🔹 Controladores de formulario
  final tipoSangreController = TextEditingController();
  final alergiasController = TextEditingController();
  final enfermedadesController = TextEditingController();
  final medicamentosController = TextEditingController();
  final antecedentesController = TextEditingController();
  final observacionesController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  bool fumador = false;
  String consumoAlcohol = 'No';

  bool cargando = true;
  String infoClave = ''; // 🔹 Aquí mostraremos la clave

  @override
  void initState() {
    super.initState();
    obtenerDatosClinicos();
  }

  // 🔹 Función para obtener datos clínicos desde PHP
  Future<void> obtenerDatosClinicos() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/doctime/BD/datos_clinicos.php"),
        body: {
          "accion": "obtener",
          "correo": widget.correo,
          "password": widget.password,
          if (widget.clavePaciente != null) "clave_paciente": widget.clavePaciente!,
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
          pesoController.text = d["peso"]?.toString() ?? "";
          alturaController.text = d["altura"]?.toString() ?? "";
          fumador = (d["fumador"]?.toLowerCase() == "si");
          consumoAlcohol = d["consumo_alcohol"] ?? "No";

          // 🔹 Mostrar siempre la clave de paciente
          infoClave = d["Clave_Paciente"] != null
              ? 'Clave de paciente: ${d["Clave_Paciente"]}'
              : widget.clavePaciente != null
                  ? 'Clave pasada desde Flutter: ${widget.clavePaciente}'
                  : 'Clave desconocida';

          cargando = false;
        });
      } else {
        setState(() {
          cargando = false;
          infoClave = "No se encontraron datos clínicos";
        });
      }
    } catch (e) {
      setState(() {
        cargando = false;
        infoClave = "Error al obtener datos";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al obtener datos: $e")),
      );
    }
  }

  // 🔹 Guardar datos clínicos (insertar o actualizar)
  Future<void> guardarDatosClinicos() async {
    if (!_formKey.currentState!.validate()) return;

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
          "fumador": fumador ? "Si" : "No",
          "consumo_alcohol": consumoAlcohol,
        },
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["message"] ?? "Error desconocido"),
          backgroundColor: data["success"] == true ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar datos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0077C2),
        title: const Text('Datos Clínicos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Encabezado
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
                              Text('Consultas y citas médicas', style: TextStyle(color: Color(0xDD000000), fontSize: 11, fontWeight: FontWeight.w500)),
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

                  const SizedBox(height: 10),

                  // 🔹 Mostrar la clave de paciente
                  Text(
                    infoClave,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Formulario de datos clínicos
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField('Tipo de sangre', tipoSangreController),
                        buildTextField('Alergias', alergiasController),
                        buildTextField('Enfermedades crónicas', enfermedadesController),
                        buildTextField('Medicamentos actuales', medicamentosController),
                        buildTextField('Antecedentes médicos', antecedentesController),
                        buildTextField('Observaciones', observacionesController),
                        buildTextField('Peso (kg)', pesoController, tipo: TextInputType.number),
                        buildTextField('Altura (m)', alturaController, tipo: TextInputType.number),
                        SwitchListTile(
                          title: const Text('¿Fumador?'),
                          value: fumador,
                          onChanged: (value) => setState(() => fumador = value),
                        ),
                        DropdownButtonFormField<String>(
                          value: consumoAlcohol,
                          decoration: const InputDecoration(labelText: 'Consumo de alcohol'),
                          items: const [
                            DropdownMenuItem(value: 'No', child: Text('No')),
                            DropdownMenuItem(value: 'Ocasional', child: Text('Ocasional')),
                            DropdownMenuItem(value: 'Frecuente', child: Text('Frecuente')),
                          ],
                          onChanged: (value) => setState(() => consumoAlcohol = value ?? 'No'),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: guardarDatosClinicos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0077C2),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          ),
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Guardar Datos Clínicos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
