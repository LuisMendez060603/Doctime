import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import '../sesion.dart';

class PatientDialog1 extends StatefulWidget {
  final String correo;
  final String password;

  const PatientDialog1({required this.correo, required this.password, super.key});

  @override
  _PatientDialog1State createState() => _PatientDialog1State();
}

class _PatientDialog1State extends State<PatientDialog1> {
  String? nombre;
  String? apellido;
  String? especialidad;
  String? telefono;
  String? direccion;
  bool _isLoading = true;

  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController especialidadController;
  late TextEditingController telefonoController;
  late TextEditingController direccionController;

  bool isEditing = false;

  String? nombreError;
  String? apellidoError;
  String? telefonoError;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    apellidoController = TextEditingController();
    especialidadController = TextEditingController();
    telefonoController = TextEditingController();
    direccionController = TextEditingController();
    _fetchProfessionalData();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    especialidadController.dispose();
    telefonoController.dispose();
    direccionController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfessionalData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost/doctime/BD/iniciar_sesion.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'correo': widget.correo,
          'password': widget.password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['tipo_usuario'] == "profesional") {
          setState(() {
            nombre = data['nombre'];
            apellido = data['apellido'];
            especialidad = data['especialidad'];
            telefono = data['telefono'];
            direccion = data['direccion'];

            nombreController.text = nombre ?? '';
            apellidoController.text = apellido ?? '';
            especialidadController.text = especialidad ?? '';
            telefonoController.text = telefono ?? '';
            direccionController.text = direccion ?? '';

            _isLoading = false;
          });
        } else {
          _showErrorDialog(context, data['message'] ?? 'No se encontraron datos');
          setState(() => _isLoading = false);
        }
      } else {
        _showErrorDialog(context, 'Error de conexión');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error de conexión');
      setState(() => _isLoading = false);
    }
  }

  bool _validateFields(String nombreTexto, String apellidoTexto, String telefonoTexto) {
    bool isValid = true;

    if (!RegExp(r"^[a-zA-ZÁÉÍÓÚáéíóúÑñ\s]+$").hasMatch(nombreTexto)) {
      setState(() => nombreError = "Solo se permiten letras y espacios");
      isValid = false;
    } else {
      setState(() => nombreError = null);
    }

    if (!RegExp(r"^[a-zA-ZÁÉÍÓÚáéíóúÑñ\s]+$").hasMatch(apellidoTexto)) {
      setState(() => apellidoError = "Solo se permiten letras y espacios");
      isValid = false;
    } else {
      setState(() => apellidoError = null);
    }

    if (!RegExp(r"^\d{0,10}$").hasMatch(telefonoTexto)) {
      setState(() => telefonoError = "Solo números, máximo 10 dígitos");
      isValid = false;
    } else {
      setState(() => telefonoError = null);
    }

    return isValid;
  }

  Future<void> _updateProfessionalData() async {
    final nombreTexto = nombreController.text.trim();
    final apellidoTexto = apellidoController.text.trim();
    final especialidadTexto = especialidadController.text.trim();
    final telefonoTexto = telefonoController.text.trim();
    final direccionTexto = direccionController.text.trim();

    // Validaciones iniciales
    if (!_validateFields(nombreTexto, apellidoTexto, telefonoTexto)) return;

    if ((nombreTexto == (nombre ?? '')) &&
        (apellidoTexto == (apellido ?? '')) &&
        (especialidadTexto == (especialidad ?? '')) &&
        (telefonoTexto == (telefono ?? '')) &&
        (direccionTexto == (direccion ?? ''))) {
      _showErrorDialog(context, 'No se detectaron cambios. Modifica al menos un campo antes de guardar.');
      return;
    }

    if (nombreTexto.isEmpty ||
        apellidoTexto.isEmpty ||
        especialidadTexto.isEmpty ||
        telefonoTexto.isEmpty ||
        direccionTexto.isEmpty) {
      _showErrorDialog(context, 'Por favor completa todos los campos antes de guardar.');
      return;
    }

    if (telefonoTexto.length != 10) {
      _showErrorDialog(context, "El teléfono debe tener exactamente 10 dígitos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost/doctime/BD/actualizar_profesional.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'correo': widget.correo,
          'nombre': nombreTexto,
          'apellido': apellidoTexto,
          'especialidad': especialidadTexto,
          'telefono': telefonoTexto,
          'direccion': direccionTexto,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          nombre = nombreTexto;
          apellido = apellidoTexto;
          especialidad = especialidadTexto;
          telefono = telefonoTexto;
          direccion = direccionTexto;
          isEditing = false;
          nombreError = null;
          apellidoError = null;
          telefonoError = null;
        });
        _showSuccessDialog();
      } else {
        _showErrorDialog(context, data['message'] ?? 'Error al actualizar');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error al actualizar datos');
    }

    setState(() => _isLoading = false);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'img/Imagen5.png',
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('img/Imagen5.png', height: 100, width: 100),
              const SizedBox(height: 10),
              const Text('¡Datos Actualizados!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              child: const Text('Aceptar', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const IniciarSesionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Datos del Profesional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (!isEditing) {
                                isEditing = true;
                              } else {
                                isEditing = false;
                                nombreController.text = nombre ?? '';
                                apellidoController.text = apellido ?? '';
                                especialidadController.text = especialidad ?? '';
                                telefonoController.text = telefono ?? '';
                                direccionController.text = direccion ?? '';
                                nombreError = null;
                                apellidoError = null;
                                telefonoError = null;
                              }
                            });
                          },
                          child: Image.asset('img/Frame (5).png', width: 30, height: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    if (!isEditing) ...[
                      _infoRow("Nombre", nombre),
                      _infoRow("Apellido", apellido),
                      _infoRow("Especialidad", especialidad),
                      _infoRow("Teléfono", telefono),
                      _infoRow("Correo", widget.correo),
                      _infoRow("Dirección", direccion),
                    ] else ...[
                      _validatedField("Nombre", nombreController, nombreError, FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÁÉÍÓÚáéíóúÑñ\s]"))),
                      _validatedField("Apellido", apellidoController, apellidoError, FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÁÉÍÓÚáéíóúÑñ\s]"))),
                      _editableField("Especialidad", especialidadController),
                      _validatedField("Teléfono", telefonoController, telefonoError, FilteringTextInputFormatter.digitsOnly, maxLength: 10),
                      _readOnlyField("Correo", widget.correo),
                      _editableField("Dirección", direccionController),
                    ],
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (isEditing)
                          ElevatedButton(
                            onPressed: () => _updateProfessionalData(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077C2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _cerrarSesion(context),
                          child: const Text('Cerrar sesión'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value ?? 'No disponible'),
          ],
        ),
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _validatedField(String label, TextEditingController controller, String? errorText, TextInputFormatter formatter, {int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            maxLength: maxLength,
            inputFormatters: [formatter],
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              counterText: "",
              errorText: errorText,
            ),
            keyboardType: (label == "Teléfono") ? TextInputType.number : TextInputType.text,
          ),
        ],
      ),
    );
  }
}
