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
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registrarUsuario() async {
    if (_nombreController.text.isEmpty ||
        _apellidoController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showWarningDialog("Por favor, complete todos los campos.");
      return;
    }

    final url = Uri.parse('http://localhost/doctime/BD/registrar.php');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": _nombreController.text,
        "apellido": _apellidoController.text,
        "telefono": _telefonoController.text,
        "correo": _correoController.text,
        "password": _passwordController.text
      }),
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
      appBar: AppBar(title: const Text('Registro')),
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

  const Frame9({
    super.key,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.correoController,
    required this.contrasenaController,
    required this.onRegistrar,
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
              Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                          decoration: const ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(5),
                                child: Image.asset("img/Imagen1.png", fit: BoxFit.cover),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DocTime',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Consultas y citas médicas',
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registrarse',
                style: TextStyle(
                  color: Color(0xFF00ADFF),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(label: 'Nombre', hint: 'Ingresa tu nombre', controller: nombreController),
              _buildTextField(label: 'Apellido', hint: 'Ingresa tu apellido', controller: apellidoController),
              _buildTextField(label: 'Teléfono', hint: 'Ingresa tu número', controller: telefonoController),
              _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', controller: correoController),
              _buildTextField(label: 'Contraseña', hint: 'Ingresa tu contraseña', controller: contrasenaController, obscureText: true),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRegistrar,
                child: Container(
                  width: double.infinity,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00ADFF),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: const Center(
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: controller,
            obscureText: obscureText,
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
