import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'citas_page.dart';
import 'patient_dialog1.dart';

class ModificarCitaProfesional extends StatefulWidget {
  final String correo;
  final String password;
  final Map<String, dynamic> cita;
  final String claveProfesional;

  const ModificarCitaProfesional({
    super.key,
    required this.correo,
    required this.password,
    required this.cita,
    required this.claveProfesional,
  });

  @override
  _ModificarCitaProfesionalState createState() => _ModificarCitaProfesionalState();
}

class _ModificarCitaProfesionalState extends State<ModificarCitaProfesional> {
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  List<String> horasDisponibles = [];
  bool _fechaElegida = false;

  @override
  void initState() {
    super.initState();
    print("Contenido de la cita recibida: ${widget.cita}");
    _fechaController.text = widget.cita['Fecha'] ?? '';
    _horaController.text = widget.cita['Hora'] ?? '';
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
        setState(() => horasDisponibles = []);
        _showErrorDialog('No se pudieron obtener las horas disponibles.');
      }
    } else {
      _showErrorDialog('Error de conexión con el servidor.');
    }
  }

  Future<void> modificarCita() async {
    final url = Uri.parse('http://localhost/doctime/BD/modificar_cita_profesional.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'clave_cita': widget.cita['Clave_Cita'],
        'nueva_fecha': _fechaController.text,
        'nueva_hora': _horaController.text,
      }),
    );

    final data = json.decode(response.body);
    if (data['success']) {
      _showSuccessDialog();
    } else {
      _showErrorDialog('Error al modificar la cita: ${data['message']}');
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
                'img/Imagen5.png', // Asegúrate de tener esta imagen en assets
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              const Text(
                '¡Cita Modificada!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        content: const SizedBox(height: 10),
        actions: <Widget>[
          Center(
            child: GestureDetector(
              onTap: () {
                String correoProfesional = 'mendez@gmail.com'; // Reemplaza con datos reales
                String passwordProfesional = '1234';

                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CitasPage(
                      correo: correoProfesional,
                      password: passwordProfesional,
                    ),
                  ),
                );
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0077C2),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaController.text = picked.toString().split(' ')[0];
        _fechaElegida = true;
      });
      await _getHorasDisponibles();
    }
  }

  Future<void> _selectHora(BuildContext context) async {
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
    }

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selecciona una hora',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                              setState(() => _horaController.text = horasDisponibles[index]);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado visual
            Row(
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
                      builder: (context) => PatientDialog1(
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
            ),
            const SizedBox(height: 20),

            Column(
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
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    hintText: "Seleccione una fecha",
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.date_range, color: Color(0xFF0077C2)),
                    filled: true,
                    fillColor: const Color(0xFFE1F5FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xA5BABABA)),
                    ),
                  ),
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
                TextFormField(
                  controller: _horaController,
                  readOnly: true,
                  onTap: () => _selectHora(context),
                  decoration: InputDecoration(
                    hintText: "Seleccione una hora",
                    hintStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.access_time, color: Color(0xFF0077C2)),
                    filled: true,
                    fillColor: const Color(0xFFE1F5FE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xA5BABABA)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: modificarCita,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Guardar cambios',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077C2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Volver',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
