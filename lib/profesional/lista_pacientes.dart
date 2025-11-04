import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_dialog1.dart'; // Ajusta esta ruta según dónde tengas el archivo

class ListaPacientesPage extends StatefulWidget {
  final String correo;
  final String password;

  const ListaPacientesPage({
    super.key,
    required this.correo,
    required this.password,
  });

  @override
  State<ListaPacientesPage> createState() => _ListaPacientesPageState();
}

class _ListaPacientesPageState extends State<ListaPacientesPage> {
  List<dynamic> pacientes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    obtenerPacientes();
  }

  Future<void> obtenerPacientes() async {
    try {
      final response = await http.get(Uri.parse('http://localhost/doctime/BD/obtener_pacientes.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            pacientes = data['pacientes'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        setState(() => isLoading = false);
        throw Exception('Error en la respuesta del servidor');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener pacientes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Encabezado visual (logo + nombre + botón perfil)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
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
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Lista de Pacientes",
                  style: TextStyle(
                    color: const Color(0xFF0077C2),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Column(
                children: [
                  // Aquí va el contenido actual de la lista de pacientes
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : pacientes.isEmpty
                            ? const Center(child: Text("No hay pacientes registrados."))
                            : ListView.builder(
                                itemCount: pacientes.length,
                                itemBuilder: (context, index) {
                                  final paciente = pacientes[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: ListTile(
                                      leading: const Icon(Icons.person, color: const Color(0xFF0077C2)),
                                      title: Text('${paciente['Nombre']} ${paciente['Apellido']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Teléfono: ${paciente['Telefono']}'),
                                          Text('Correo: ${paciente['Correo']}'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),

                  // Botón de regreso
                  Padding(
                    padding: const EdgeInsets.all(16.0), // Espaciado para el botón
                    child: SizedBox(
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
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
