import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'confirmar_correo_page.dart';

// 🔹 Evita el efecto azul al hacer scroll
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

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
  final TextEditingController _confirmarPasswordController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  String _selectedRole = 'paciente';
  bool _verPassword = false;
  bool _verConfirmarPassword = false;

  bool _esPasswordSegura(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> _registrarUsuario() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final telefono = _telefonoController.text.trim();
    final correo = _correoController.text.trim();
    final password = _passwordController.text;
    final confirmarPassword = _confirmarPasswordController.text;

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        telefono.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      _showWarningDialog("Por favor, complete todos los campos.");
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(nombre) || RegExp(r'[0-9]').hasMatch(apellido)) {
      _showWarningDialog("El nombre y el apellido no deben contener números.");
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

    if (!_esPasswordSegura(password)) {
      _showWarningDialog(
          "La contraseña debe tener mínimo 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial.");
      return;
    }

    if (password != confirmarPassword) {
      _showWarningDialog("Las contraseñas no coinciden.");
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
        _showSuccessDialog();
      } else {
        _showWarningDialog(responseData["message"]);
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
              Image.asset('img/Imagen5.png', height: 100, width: 100),
              const SizedBox(height: 10),
              const Text(
                '¡Registro Exitoso!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        content: const Text("Se ha enviado un código de verificación a tu correo."),
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
            Image.asset('img/Imagen5.png', height: 100, width: 100),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              'Cerrar',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(), // 🔹 elimina el color azul al hacer scroll
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // 🔹 Cabecera personalizada (reemplazo del AppBar)
                Stack(
                  children: [
                    // Flecha de regresar alineada a la izquierda y centrada verticalmente
                    Positioned(
                      left: 0,
                      top: 60, // 🔹 Ajusta este valor si la quieres un poco más arriba o abajo
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF0077C2)),
                        onPressed: () => Navigator.of(context).pop(),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),

                    // Contenido centrado (logo + texto)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(5),
                              child: Image.asset("img/logo.png", fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 8),
                            Column(
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
                                    color: Color.fromARGB(230, 0, 0, 0),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),


              // 🔹 Contenido del formulario
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
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
                        confirmarController: _confirmarPasswordController,
                        onRegistrar: _registrarUsuario,
                        role: _selectedRole,
                        onRoleChanged: (v) => setState(() => _selectedRole = v),
                        especialidadController: _especialidadController,
                        direccionController: _direccionController,
                        showWarning: (msg) => _showWarningDialog(msg),
                        verPassword: _verPassword,
                        verConfirmar: _verConfirmarPassword,
                        toggleVerPassword: () => setState(() => _verPassword = !_verPassword),
                        toggleVerConfirmar: () =>
                            setState(() => _verConfirmarPassword = !_verConfirmarPassword),
                      ),
                    );
                  },
                ),
              ),
            ],
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
  final TextEditingController confirmarController;
  final VoidCallback onRegistrar;
  final String role;
  final ValueChanged<String> onRoleChanged;
  final TextEditingController especialidadController;
  final TextEditingController direccionController;
  final ValueChanged<String> showWarning;
  final bool verPassword;
  final bool verConfirmar;
  final VoidCallback toggleVerPassword;
  final VoidCallback toggleVerConfirmar;

  const Frame9({
    super.key,
    required this.nombreController,
    required this.apellidoController,
    required this.telefonoController,
    required this.correoController,
    required this.contrasenaController,
    required this.confirmarController,
    required this.onRegistrar,
    required this.role,
    required this.onRoleChanged,
    required this.especialidadController,
    required this.direccionController,
    required this.showWarning,
    required this.verPassword,
    required this.verConfirmar,
    required this.toggleVerPassword,
    required this.toggleVerConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        _buildTextField(
            label: 'Teléfono',
            hint: 'Ingresa tu número',
            controller: telefonoController,
            keyboardType: TextInputType.number),
        _buildTextField(label: 'Correo Electrónico', hint: 'Ingresa tu correo', controller: correoController),
        _buildTextField(
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            controller: contrasenaController,
            obscureText: !verPassword,
            suffixIcon: IconButton(
              icon: Icon(verPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVerPassword,
            )),
        _buildTextField(
            label: 'Confirmar Contraseña',
            hint: 'Repite tu contraseña',
            controller: confirmarController,
            obscureText: !verConfirmar,
            suffixIcon: IconButton(
              icon: Icon(verConfirmar ? Icons.visibility_off : Icons.visibility),
              onPressed: toggleVerConfirmar,
            )),
        if (role == 'profesional') ...[
          const SizedBox(height: 12),
          _buildTextField(label: 'Especialidad', hint: 'Ingresa tu especialidad', controller: especialidadController),
          _buildTextField(label: 'Dirección', hint: 'Ingresa tu dirección', controller: direccionController),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onRegistrar,
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.resolveWith<Color>((states) => const Color(0xFF0077C2)),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
