import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_dialog.dart';
import 'paciente1.dart';

class ModificarCita extends StatefulWidget {
  final String correo;
  final String password;
  final Map<String, dynamic> cita;
  final String claveProfesional;

  const ModificarCita({
    super.key,
    required this.correo,
    required this.password,
    required this.cita,
    required this.claveProfesional,
  });

  @override
  _ModificarCitaState createState() => _ModificarCitaState();
}

class _ModificarCitaState extends State<ModificarCita> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  List<String> horasDisponibles = [];

  // Flag que indica si se ha seleccionado una fecha nueva manualmente.
  bool _fechaElegida = false;

  @override
  void initState() {
    super.initState();
    // Puedes dejar el valor inicial si corresponde o dejarlo vacío para forzar la selección.
    _fechaController.text = widget.cita['fecha'] ?? '';
    _horaController.text = widget.cita['hora'] ?? '';
  }

  Future<void> _getHorasDisponibles() async {
    final url = Uri.parse('http://localhost/doctime/BD/obtener_horas_disponibles.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fecha': _fechaController.text,
        'clave_profesional': widget.claveProfesional,
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

  Future<void> modificarCita() async {
    final url = Uri.parse('http://localhost/doctime/BD/modificar_cita.php');

    final response = await http.post(
      url,
      body: jsonEncode({
        'correo': widget.correo,
        'password': widget.password,
        'clave_cita': widget.cita['clave_cita'],
        'nueva_fecha': _fechaController.text,
        'nueva_hora': _horaController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (data['success']) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message']}')),
      );
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
                'img/Imagen5.png', // Asegúrate de tener la imagen en la ruta correcta
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Cita Modificada!',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                  MaterialPageRoute(
                    builder: (context) => Paciente1(
                      correo: widget.correo,
                      password: widget.password,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        // Actualizamos el campo de fecha y marcamos que se eligió manualmente.
        _fechaController.text = "${pickedDate.toLocal()}".split(' ')[0];
        _fechaElegida = true;
      });
      _getHorasDisponibles();
    }
  }

  Future<void> _selectHora(BuildContext context) async {
    // Verificamos que el usuario haya seleccionado una fecha manualmente
    if (!_fechaElegida) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'img/Imagen5.png', // Imagen de advertencia
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Seleccione una fecha primero',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                },
              ),
            ),
          ],
        ),
      );
      return;
    } else {
      // Si la fecha fue elegida, mostramos el modal de selección de hora.
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
                  child: horasDisponibles.isEmpty
                      ? const Center(child: Text('No hay horas disponibles.'))
                      : ListView.builder(
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
            _buildHeaderConImagenes(),
            const SizedBox(height: 30),
            _buildForm(),
            const SizedBox(height: 20),
            _buildVolverButton(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderConImagenes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
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
              const Flexible(
                child: Column(
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
              ),
            ],
          ),
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

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFechaHoraFields(),
        const SizedBox(height: 20),
        _buildGuardarButton(),
      ],
    );
  }

  Widget _buildGuardarButton() {
    return SizedBox(
      width: double.infinity,
      child: _estiloBotonBase(
        onPressed: modificarCita,
        texto: 'Guardar cambios',
      ),
    );
  }

  Widget _buildVolverButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: _estiloBotonBase(
        onPressed: () => Navigator.pop(context),
        texto: 'Volver',
      ),
    );
  }

  Widget _estiloBotonBase({required VoidCallback onPressed, required String texto}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0077C2),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        texto,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
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

  Widget _buildFechaHoraFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de la cita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        _customDateField(
          label: "Fecha",
          hint: "Seleccione una fecha",
          controller: _fechaController,
          icon: Icons.date_range,
          onTap: () => _selectDate(context),
        ),
        const SizedBox(height: 20),
        const Text(
          'Hora de la cita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
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
      ],
    );
  }
}
