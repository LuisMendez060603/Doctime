import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'patient_dialog1.dart'; // Asegúrate de ajustar la ruta correctamente
import 'ModificarCitaProfesional.dart'; // Ajusta el nombre según tu archivo
import 'ConsultaMedicaPage.dart'; // Asegúrate de ajustar la ruta correctamente

class CitasPage extends StatefulWidget {
  final String correo;
  final String password;

  const CitasPage({super.key, required this.correo, required this.password});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  List<dynamic> citas = [];
  bool isLoading = true;
  String error = '';
  bool mostrarCitasDeHoy = true;

  @override
  void initState() {
    super.initState();
    obtenerCitas();
  }

  Future<void> obtenerCitas() async {
    const String url = 'http://localhost/doctime/BD/obtener_citas_profesional.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': widget.correo}),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          citas = data['citas'].map((cita) {
            cita['botonesDeshabilitados'] = false; // Agregar estado individual para deshabilitar botones
            return cita;
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error al conectar con el servidor';
        isLoading = false;
      });
    }
  }

  List<dynamic> filtrarCitas(bool hoy) {
    final hoyStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return citas.where((cita) {
      final fecha = cita['Fecha'];
      return hoy ? fecha == hoyStr : fecha.compareTo(hoyStr) > 0;
    }).toList();
  }

  // Método para mostrar el diálogo de éxito
  void _showSuccessDialog(String message, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                imagePath, // Asegúrate de tener esta imagen en assets
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
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
                obtenerCitas(); // Recargar las citas después de la acción
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citasFiltradas = filtrarCitas(mostrarCitasDeHoy);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Encabezado visual
              Row(
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

                  // Imagen perfil profesional - con onTap
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => PatientDialog1(
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

              // Botones de filtro
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mostrarCitasDeHoy = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mostrarCitasDeHoy ? const Color(0xFF0077C2) : Colors.white,
                        foregroundColor: mostrarCitasDeHoy ? Colors.white : const Color(0xFF0077C2),
                        side: const BorderSide(color: Color(0xFF0077C2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Citas de Hoy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          mostrarCitasDeHoy = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !mostrarCitasDeHoy ? const Color(0xFF0077C2) : Colors.white,
                        foregroundColor: !mostrarCitasDeHoy ? Colors.white : const Color(0xFF0077C2),
                        side: const BorderSide(color: Color(0xFF0077C2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Próximas Citas'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Lista de citas
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error.isNotEmpty
                        ? Center(child: Text(error))
                        : citasFiltradas.isEmpty
                            ? const Center(child: Text('No hay citas para mostrar.'))
                            : ListView.builder(
                                itemCount: citasFiltradas.length,
                                itemBuilder: (context, index) {
                                  final cita = citasFiltradas[index];
                                  return GestureDetector(
                                    onTap: () {
                                      final hoyStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                                      if (cita['Fecha'] == hoyStr) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            contentPadding: const EdgeInsets.all(20),
                                            backgroundColor: Colors.blue[50], // Fondo más suave para el diálogo
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.local_hospital, // Icono de consulta médica
                                                  color: const Color(0xFF0077C2), // Color azul
                                                  size: 50,
                                                ),
                                                const SizedBox(height: 20),
                                                const Text(
                                                  'Opciones de la Cita',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 10, 10, 10),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 20),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFF0077C2),
                                                    foregroundColor: Colors.white,
                                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    elevation: 5,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context); // Cierra el diálogo
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ConsultaMedicaPage(
                                                          correo: widget.correo,
                                                          password: widget.password,
                                                          cita: cita,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text('Consulta', style: TextStyle(fontSize: 18)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    },


                                    child: Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: const Icon(Icons.calendar_today, color: Colors.blue),
                                              title: Text('Paciente: ${cita['Nombre_Paciente']}'),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Fecha: ${cita['Fecha']} - Hora: ${cita['Hora']}'),
                                                  Text(
                                                    'Estado: ${cita['Estado'][0].toUpperCase()}${cita['Estado'].substring(1).toLowerCase()}',
                                                    style: TextStyle(
                                                      color: cita['Estado'].toLowerCase() == 'confirmada'
                                                          ? Colors.green
                                                          : cita['Estado'].toLowerCase() == 'cancelada'
                                                              ? Colors.red
                                                              : cita['Estado'].toLowerCase() == 'modificada'
                                                                  ? Colors.orange
                                                                  : cita['Estado'].toLowerCase() == 'activa'
                                                                      ? const Color(0xFF0077C2)
                                                                      : const Color(0xFF0077C2),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                // Botón Confirmar, solo si el estado no es "Confirmada" ni "Cancelada"
                                                if (!cita['Estado'].toString().toLowerCase().contains('confirmada') &&
                                                    !cita['Estado'].toString().toLowerCase().contains('cancelada') &&
                                                    !cita['botonesDeshabilitados'])

                                                  TextButton(
                                                    onPressed: () async {
                                                      final confirmar = await mostrarDialogoConfirmacionConfirmar(context);
                                                      if (confirmar == true) {
                                                        final claveCita = cita['Clave_Cita'];
                                                        final url = 'http://localhost/doctime/BD/confirmar_cita.php';

                                                        try {
                                                          final response = await http.post(
                                                            Uri.parse(url),
                                                            headers: {'Content-Type': 'application/json'},
                                                            body: jsonEncode({'clave_cita': claveCita}),
                                                          );

                                                          final result = jsonDecode(response.body);
                                                          if (result['success']) {
                                                            setState(() {
                                                              cita['botonesDeshabilitados'] = true; // Deshabilitar los botones solo para esta cita
                                                              cita['Estado'] = 'Confirmada'; // Cambiar el estado de la cita
                                                            });
                                                            _showSuccessDialog('¡Cita Confirmada!', 'img/Imagen5.png');
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Error: ${result['message']}')),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Error al confirmar la cita')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.green,
                                                    ),
                                                    child: const Text('Confirmar'),
                                                  ),

                                                const SizedBox(width: 10),

                                                
                                                // Botón Modificar, solo si el estado no es "Confirmada" ni "Cancelada"
                                                if (!cita['Estado'].toString().toLowerCase().contains('confirmada') &&
                                                    !cita['Estado'].toString().toLowerCase().contains('cancelada') &&
                                                    !cita['botonesDeshabilitados'])
                                                  TextButton(
                                                    onPressed: () async {
                                                      final modificar = await mostrarDialogoConfirmacionModificar(context);
                                                      if (modificar == true) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => ModificarCitaProfesional(
                                                              correo: widget.correo,
                                                              password: widget.password,
                                                              cita: cita,
                                                              claveProfesional: cita['Clave_Profesional'], // Usa la clave del profesional de la cita
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.orange,
                                                    ),
                                                    child: const Text('Modificar'),
                                                  ),


                                                const SizedBox(width: 10),

                                                // Botón Cancelar, solo si el estado no es "Cancelada"
                                                if (cita['Estado'] != 'Cancelada' && !cita['botonesDeshabilitados'])
                                                  TextButton(
                                                    onPressed: () async {
                                                      final confirmar = await mostrarDialogoConfirmacion(context);
                                                      if (confirmar == true) {
                                                        final claveCita = cita['Clave_Cita'];
                                                        final url = 'http://localhost/doctime/BD/cancelar_cita_profesional.php';

                                                        try {
                                                          final response = await http.post(
                                                            Uri.parse(url),
                                                            headers: {'Content-Type': 'application/json'},
                                                            body: jsonEncode({'clave_cita': claveCita}),
                                                          );

                                                          final result = jsonDecode(response.body);
                                                          if (result['success']) {
                                                            setState(() {
                                                              cita['Estado'] = 'Cancelada';
                                                              cita['botonesDeshabilitados'] = true;
                                                            });
                                                            _showSuccessDialog('¡Cita Cancelada!', 'img/Imagen5.png');
                                                          } else {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Error: ${result['message']}')),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Error al cancelar la cita')),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                    ),
                                                    child: const Text('Cancelar'),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),

              const SizedBox(height: 10),

              // Botón de regreso
              SizedBox(
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
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<bool?> mostrarDialogoConfirmacion(BuildContext context) async {
  final width = MediaQuery.of(context).size.width;
  final isSmallScreen = width < 600;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'img/Imagen4.png',
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 100 : 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            '¿Estás seguro que deseas cancelar esta cita?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sí, cancelar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
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

Future<bool?> mostrarDialogoConfirmacionConfirmar(BuildContext context) async {
  final width = MediaQuery.of(context).size.width;
  final isSmallScreen = width < 600;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'img/Imagen5.png', // Cambia la imagen si lo deseas
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 100 : 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            '¿Estás seguro que deseas confirmar esta cita?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sí, confirmar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
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

Future<bool?> mostrarDialogoConfirmacionModificar(BuildContext context) async {
  final width = MediaQuery.of(context).size.width;
  final isSmallScreen = width < 600;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'img/Imagen6.png', // Cambia la imagen si tienes una específica para modificar
            width: isSmallScreen ? 100 : 150,
            height: isSmallScreen ? 100 : 150,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            '¿Estás seguro que deseas modificar esta cita?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sí, modificar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077C2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
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



