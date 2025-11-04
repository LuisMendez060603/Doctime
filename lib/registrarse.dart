import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'confirmar_correo_page.dart'; // <-- importar la página de confirmación

class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  _RegistrarsePageState createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String _selectedRole = 'paciente'; // <-- 'paciente' o 'profesional'

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        telefono.isEmpty ||
        correo.isEmpty ||
        password.isEmpty) {
      _showWarningDialog("Por favor, complete todos los campos.");
      return;
    }

    final telefonoSoloDigitos = RegExp(r'^\d+$').hasMatch(telefono);
    if (!telefonoSoloDigitos || telefono.length != 10) {
      _showWarningDialog("Teléfono inválido. Debe contener exactamente 10 dígitos.");
      return;
    }

    final correoValido = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(correo);
    if (!correoValido) {
      _showWarningDialog("Correo inválido. Debe contener '@' y un dominio '.'");
      return;
    }

    if (_selectedRole == 'profesional') {
      if (_especialidadController.text.trim().isEmpty ||
          _direccionController.text.trim().isEmpty) {
        _showWarningDialog("Por favor, complete los datos del profesional.");
        return;
      }
    }

    final url = Uri.parse('http://localhost/doctime/BD/registrar.php');

    final Map<String, dynamic> body = {
      "nombre": nombre,
      "apellido": apellido,
      "telefono": telefono,
      "correo": correo,
      "password": password,
      "role": _selectedRole,
    };

    if (_selectedRole == 'profesional') {
      body.addAll({
        "Especialidad": _especialidadController.text.trim(),
        "Direccion": _direccionController.text.trim(),
      });
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      if (responseData["success"]) {
        _showSuccessDialog(); // <-- redirige a ConfirmarCorreoPage
      } else {
        _showWarningDialog("Error: ${responseData["message"]}");
      }
    } catch (e) {
      _showWarningDialog("Error de conexión. Intenta de nuevo.");
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
                'img/Imagen5.png',
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Registro Exitoso!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          "Se ha enviado un código de verificación a tu correo. Ingresa el código para activar tu cuenta.",
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Redirigir a la página de confirmación de correo
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ConfirmarCorreoPage(correo: _correoController.text.trim()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'img/Imagen5.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0077C2)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: const Color(0xFF0077C2),
          onPressed: () => Navigator.of(context).pop(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 85,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 8),
              child: Image.asset("img/logo.png", fit: BoxFit.contain),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DocTime',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Consultas y citas médicas',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.9),
                  child: Frame9(
                    nombreController: _nombreController,
                    apellidoController: _apellidoController,
                    telefonoController: _telefonoController,
                    correoController: _correoController,
                    contrasenaController: _passwordController,
                    onRegistrar: _registrarUsuario,
                    role: _selectedRole,
                    onRoleChanged: (v) => setState(() => _selectedRole = v),
                    especialidadController: _especialidadController,
                    direccionController: _direccionController,
                    showWarning: (msg) => _showWarningDialog(msg),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class Frame9 extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController telefonoController;
  final TextEditingController correoController;
  final TextEditingController contrasenaController;
  final VoidCallback onRegistrar;
  final String role;
  final ValueChanged<String> onRoleChanged;
  final TextEditingController especialidadController;
  final TextEditingController direccionController;
  final ValueChanged<String> showWarning;

  const Frame9({
    super.key,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.correoController,
    required this.contrasenaController,
    required this.onRegistrar,
    required this.role,
    required this.onRoleChanged,
    required this.especialidadController,
    required this.direccionController,
    required this.showWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Registrarse',
                style: TextStyle(
                  color: Color(0xFF0077C2),
                  fontSize: 23,
                  fontFamily: 'Euclid Circular A',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Paciente'),
                    selected: role == 'paciente',
                    onSelected: (s) {
                      if (s) onRoleChanged('paciente');
                    },
                    selectedColor: const Color(0xFF0077C2),
                    labelStyle: TextStyle(
                      color: role == 'paciente' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Profesional'),
                    selected: role == 'profesional',
                    onSelected: (s) {
                      if (s) onRoleChanged('profesional');
                    },
                    selectedColor: const Color(0xFF0077C2),
                    labelStyle: TextStyle(
                      color: role == 'profesional' ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(label: 'Nombre', hint: 'Ingresa tu nombre', controller: nombreController),
              _buildTextField(label: 'Apellido', hint: 'Ingresa tu apellido', controller: apellidoController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teléfono',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa tu número',
                        hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Color(0xFFBDBDBD)),
                        ),
                      ),
                      onChanged: (value) {
                        final filtered = value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (filtered != value) {
                          telefonoController.text = filtered;
                          telefonoController.selection = TextSelection.fromPosition(
                              TextPosition(offset: filtered.length));
                          showWarning('Sólo se permiten números en Teléfono');
                        }
                      },
                    ),
                  ],
                ),
              ),
              _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', controller: correoController),
              _buildTextField(label: 'Contraseña', hint: 'Ingresa tu contraseña', controller: contrasenaController, obscureText: true),
              if (role == 'profesional') ...[
                const SizedBox(height: 12),
                _buildTextField(label: 'Especialidad', hint: 'Ingresa tu especialidad', controller: especialidadController),
                _buildTextField(label: 'Dirección', hint: 'Ingresa tu dirección', controller: direccionController),
              ],
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onRegistrar,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return const Color(0xFF005A9C); // color hover
                    }
                    return const Color(0xFF0077C2); // color normal
                  }),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // texto blanco
                  overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black12; // color cuando presionas el botón
                      }
                      return null; // otros estados usan default
                    },
                  ),
                  minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Euclid Circular A',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
