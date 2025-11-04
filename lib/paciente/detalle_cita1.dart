import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detalle_cita2.dart';
import 'patient_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleCita1 extends StatefulWidget {
  final String correo;
  final String password;

  const DetalleCita1({super.key, required this.correo, required this.password});

  @override
  _DetalleCita1State createState() => _DetalleCita1State();
}

class _DetalleCita1State extends State<DetalleCita1> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('clave_paciente', data['clave_paciente'].toString());

        setState(() {
          _nombreController.text = data['nombre'];
          _apellidoController.text = data['apellido'];
          _telefonoController.text = data['telefono'];
          _isLoading = false;
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

  Future<void> _guardarCambios() async {
    final prefs = await SharedPreferences.getInstance();
    final clavePaciente = prefs.getString('clave_paciente') ?? '';

    final response = await http.post(
      Uri.parse('http://localhost/doctime/BD/actualizar_paciente.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'clave_paciente': clavePaciente,
        'nombre': _nombreController.text,
        'apellido': _apellidoController.text,
        'telefono': _telefonoController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(context, data['message']);
      }
    } else {
      _showErrorDialog(context, 'Error al actualizar los datos');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
                'img/Imagen5.png', // Asegúrate que esta imagen esté en assets
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
                Navigator.of(context).pop();
                // Opcional: puedes hacer Navigator.pop(context); para volver a pantalla anterior
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE1F5FE),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: Color(0xA5BABABA)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Cabecera
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
                        Text(
                          'DocTime',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Consultas y citas médicas',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
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

            const SizedBox(height: 30),

            // Títulos
            Text(
              'Agendar Cita Médica',
              style: TextStyle(
                color: const Color(0xFF0077C2),
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Euclid Circular A',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Detalles de la cita',
              style: TextStyle(
                color: Colors.black,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Euclid Circular A',
              ),
            ),
            const SizedBox(height: 30),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _editableField("Nombre", _nombreController),
                      _editableField("Apellido", _apellidoController),
                      _editableField("Correo", TextEditingController(text: widget.correo), readOnly: true),
                      _editableField("Teléfono", _telefonoController),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _guardarCambios,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30, vertical: 12),
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),

            const SizedBox(height: 20),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: isSmallScreen ? 130 : 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  width: isSmallScreen ? 130 : 150,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final clavePaciente = prefs.getString('clave_paciente') ?? '';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleCita2(
                            correo: widget.correo,
                            password: widget.password,
                            clavePaciente: clavePaciente,
                            
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
