import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../sesion.dart';

class PatientDialog extends StatefulWidget {
  final String correo;
  final String password;

  const PatientDialog({required this.correo, required this.password});

  @override
  _PatientDialogState createState() => _PatientDialogState();
}

class _PatientDialogState extends State<PatientDialog> {
  String? nombre;
  String? apellido;
  String? telefono;
  bool _isLoading = true;

  // Agregar controladores para edición
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController telefonoController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController();
    apellidoController = TextEditingController();
    telefonoController = TextEditingController();
    _fetchPatientData();
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    telefonoController.dispose();
    super.dispose();
  }

  // Agregar método para actualizar datos
  Future<void> _updatePatientData() async {
    // Tomar textos y limpiar espacios
    final nombreTexto = nombreController.text.trim();
    final apellidoTexto = apellidoController.text.trim();
    final telefonoTexto = telefonoController.text.trim();

    // Si no hubo cambios respecto a los datos actuales, avisar y salir
    if ((nombreTexto == (nombre ?? '')) &&
        (apellidoTexto == (apellido ?? '')) &&
        (telefonoTexto == (telefono ?? ''))) {
      _showErrorDialog(context, 'No se detectaron cambios. Modifica al menos un campo antes de guardar.');
      return;
    }

    // Validación simple: si el usuario dejó campos obligatorios vacíos
    if (nombreTexto.isEmpty || apellidoTexto.isEmpty || telefonoTexto.isEmpty) {
      _showErrorDialog(context, 'Por favor completa todos los campos antes de guardar.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost/doctime/BD/actualizar_paciente.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'correo': widget.correo,
          'nombre': nombreTexto,
          'apellido': apellidoTexto,
          'telefono': telefonoTexto,
        }),
      );

      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          nombre = nombreTexto;
          apellido = apellidoTexto;
          telefono = telefonoTexto;
          isEditing = false;
        });
        _showSuccessDialog(); // <-- mostrar diálogo de éxito aquí
      } else {
        _showErrorDialog(context, data['message']);
      }
    } catch (e) {
      _showErrorDialog(context, 'Error al actualizar datos');
    }

    setState(() => _isLoading = false);
  }

  // Modificar _fetchPatientData para actualizar controladores
  Future<void> _fetchPatientData() async {
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
      if (data['success']) {
        setState(() {
          nombre = data['nombre'];
          apellido = data['apellido'];
          telefono = data['telefono'];
          _isLoading = false;

          // Actualizar controladores
          nombreController.text = nombre ?? '';
          apellidoController.text = apellido ?? '';
          telefonoController.text = telefono ?? '';
        });
      } else {
        _showErrorDialog(context, data['message']);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorDialog(context, 'Error de conexión');
      setState(() {
        _isLoading = false;
      });
    }
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
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

  // Nuevo: diálogo de éxito después de guardar
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'img/Imagen5.png', // Asegúrate que esté en assets
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Datos Actualizados!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
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
                Navigator.of(context).pop(); // cierra el diálogo de éxito
                // Si deseas cerrar también el dialog principal del paciente:
                // Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
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
                        const Text(
                          'Datos del Paciente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Si no está en edición, entrar en modo edición.
                            // Si ya está en edición, salir del modo edición y descartar cambios.
                            if (!isEditing) {
                              setState(() => isEditing = true);
                            } else {
                              setState(() {
                                isEditing = false;
                                // Restablecer controladores a los valores actuales (descartar cambios)
                                nombreController.text = nombre ?? '';
                                apellidoController.text = apellido ?? '';
                                telefonoController.text = telefono ?? '';
                              });
                            }
                          },
                          child: Image.asset(
                            'img/Frame (5).png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    if (!isEditing) ...[
                      _infoRow("Nombre", nombre),
                      _infoRow("Apellido", apellido),
                      _infoRow("Correo", widget.correo), // Mostrar correo como texto cuando NO está en edición
                      _infoRow("Teléfono", telefono),
                    ] else ...[
                      _editableField("Nombre", nombreController),
                      _editableField("Apellido", apellidoController),
                      _readOnlyField("Correo", widget.correo), // Mostrar correo en cuadro readonly solo en edición
                      _editableField("Teléfono", telefonoController),
                    ],
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        // Botón Guardar visible solo en modo edición
                        if (isEditing) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _updatePatientData(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077C2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Guardar',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _cerrarSesion(context),
                            child: const Text('Cerrar sesión'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
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
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value ?? 'No disponible',
            ),
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
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
