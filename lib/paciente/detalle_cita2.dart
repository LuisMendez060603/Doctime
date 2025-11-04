import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_dialog.dart';
import 'paciente1.dart';

class DetalleCita2 extends StatefulWidget {
  final String correo;
  final String password;
  final String clavePaciente;

  const DetalleCita2({
    super.key,
    required this.correo,
    required this.password,
    required this.clavePaciente,
  });

  @override
  State<DetalleCita2> createState() => _DetalleCita2State();
}

class _DetalleCita2State extends State<DetalleCita2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  List<String> horasDisponibles = [];

  Future<void> _agendarCita() async {
    final url = Uri.parse('http://localhost/doctime/BD/agendar_cita.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fecha': _fechaController.text,
          'hora': _horaController.text,
          'clave_paciente': widget.clavePaciente,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      'img/Imagen4.png',
                      height: 100,
                      width: 100,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data['success'] ? '¡Cita Agendada!' : 'Error',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                      if (data['success']) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Paciente1(
                              correo: widget.correo,
                              password: widget.password,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        );
      } else {
        _showErrorDialog(
            'Error de conexión con el servidor. Código: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error de conexión con el servidor: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectFecha() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
        _getHorasDisponibles();
      });
    }
  }

  Future<void> _selectHora(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona una hora',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: horasDisponibles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(horasDisponibles[index]),
                      onTap: () {
                        setState(() {
                          _horaController.text = horasDisponibles[index];
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getHorasDisponibles() async {
    final url =
        Uri.parse('http://localhost/doctime/BD/obtener_horas_disponibles.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fecha': _fechaController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          horasDisponibles = List<String>.from(data['horas_disponibles']);
        });
      } else {
        setState(() {
          horasDisponibles = [];
        });
        _showErrorDialog('No se pudieron obtener las horas disponibles.');
      }
    } else {
      _showErrorDialog('Error de conexión con el servidor.');
    }
  }

  @override
  void initState() {
    super.initState();
    _getHorasDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 30),
            const Text(
              'Agendar Cita Médica',
              style: TextStyle(
                color: Color(0xFF0077C2),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Euclid Circular A',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Detalles de la cita',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Euclid Circular A',
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Fecha de la cita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _customDateField(
                        label: "Fecha",
                        hint: "Seleccione una fecha",
                        controller: _fechaController,
                        icon: Icons.date_range,
                        onTap: _selectFecha,
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Hora de la cita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _customDateField(
                        label: "Hora",
                        hint: "Seleccione una hora",
                        controller: _horaController,
                        icon: Icons.access_time,
                        onTap: () => _selectHora(context),
                      ),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 20),
                      _buildBackButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
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
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("img/Imagen2.png"),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customDateField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese $label' : null,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF0077C2)),
        filled: true,
        fillColor: const Color(0xFFE1F5FE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xA5BABABA)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _agendarCita();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077C2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Agendar Cita',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: double.infinity,
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
    );
  }
}
