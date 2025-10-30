import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Importa tu main.dart aquí

class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  _RegistrarsePageState createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> {
  // Eliminar el controller de clave profesional
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String _selectedRole = 'paciente'; // <-- nuevo: 'paciente' o 'profesional'

  Future<void> _registrarUsuario() async {
    // Validaciones básicas
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showWarningDialog("Por favor, complete todos los campos.");
      return;
    }

    // Si es profesional, validar campos extra
    if (_selectedRole == 'profesional') {
      if (_especialidadController.text.isEmpty ||
          _direccionController.text.isEmpty) {
        _showWarningDialog("Por favor, complete los datos del profesional.");
        return;
      }
    }

    final url = Uri.parse('http://localhost/doctime/BD/registrar.php');

    // Armar body según rol
    final Map<String, dynamic> body = {
      "nombre": _nombreController.text,
      "apellido": _apellidoController.text,
      "telefono": _telefonoController.text,
      "correo": _correoController.text,
      "password": _passwordController.text,
      "role": _selectedRole,
    };

    if (_selectedRole == 'profesional') {
      body.addAll({
        "Especialidad": _especialidadController.text,
        "Direccion": _direccionController.text,
      });
    }

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);
    if (responseData["success"]) {
      _showSuccessDialog();
    } else {
      _showWarningDialog("Error: ${responseData["message"]}");
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
                'img/Imagen5.png', // Asegúrate de que la imagen exista en assets
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
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
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
            'img/Imagen5.png', // Usa la misma imagen o una diferente para advertencia
            height: 100,
            width: 100,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold, // Pone el mensaje en negritas
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
        toolbarHeight: 85, // Aumentar altura del AppBar
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, // Reducir tamaño del logo
              height: 80,
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(bottom: 8), // Agregar margen inferior
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

                    // pasar nuevos controllers para profesional
                    especialidadController: _especialidadController,
                    direccionController: _direccionController,
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
  final String role; // <-- nuevo
  final ValueChanged<String> onRoleChanged; // <-- nuevo

  // Nuevos controllers para profesional
  final TextEditingController especialidadController;
  final TextEditingController direccionController;

  const Frame9({
    super.key,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.correoController,
    required this.contrasenaController,
    required this.onRegistrar,
    required this.role, // <-- nuevo
    required this.onRoleChanged, // <-- nuevo

    // Inicializar nuevos controllers para profesional
    required this.especialidadController,
    required this.direccionController,
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
              // Bloque de logo eliminado porque ya está en el AppBar
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
              // Selección de rol
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
              _buildTextField(label: 'Teléfono', hint: 'Ingresa tu número', controller: telefonoController),
              _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', controller: correoController),
              _buildTextField(label: 'Contraseña', hint: 'Ingresa tu contraseña', controller: contrasenaController, obscureText: true),
               // Campos adicionales para profesional
              if (role == 'profesional') ...[
                const SizedBox(height: 12),
                _buildTextField(label: 'Especialidad', hint: 'Ingresa tu especialidad', controller: especialidadController),
                _buildTextField(label: 'Dirección', hint: 'Ingresa tu dirección', controller: direccionController),
              ],
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRegistrar,
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0077C2),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: const Center(
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Euclid Circular A',
                      ),
                    ),
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
              color: Colors.black, // <-- Letras en negro
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.black), // <-- Texto ingresado en negro
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
