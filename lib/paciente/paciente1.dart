import 'package:flutter/material.dart';
import 'patient_dialog.dart';
import 'detalle_cita1.dart';
import 'historial_citas.dart';
import 'ai_chat_dialog.dart';
import 'detalle_datos_clinicos.dart'; // 🔹 Nueva pantalla

class Paciente1 extends StatelessWidget {
  final String correo;
  final String password;

  const Paciente1({Key? key, required this.correo, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double scale = constraints.maxWidth / 400;
        scale = scale < 0.8 ? 0.8 : scale;
        scale = scale > 1.5 ? 1.5 : scale;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Container(
              width: constraints.maxWidth * 0.95,
              padding: EdgeInsets.all(10 * scale),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20 * scale),
                    Header(correo: correo, password: password, scale: scale),
                    SizedBox(height: 20 * scale),
                    Frame14(scale: scale),
                    SizedBox(height: 20 * scale),
                    AgendaCard(correo: correo, password: password, scale: scale),
                    SizedBox(height: 15 * scale),
                    HistorialCard(correo: correo, password: password, scale: scale),
                    SizedBox(height: 15 * scale),
                    DatosClinicosCard(correo: correo, password: password, scale: scale), // 🔹 Nueva tarjeta
                    SizedBox(height: 20 * scale),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AIChatDialog(correo: correo),
              );
            },
            backgroundColor: const Color(0xFF0077C2),
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
        );
      },
    );
  }
}

class Header extends StatelessWidget {
  final String correo;
  final String password;
  final double scale;

  const Header({super.key, required this.correo, required this.password, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Container(
                width: 50 * scale,
                height: 50 * scale,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("img/logo.png"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DocTime',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Consultas y citas médicas',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11 * scale,
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
              builder: (context) => PatientDialog(correo: correo, password: password),
            );
          },
          child: Container(
            width: 50 * scale,
            height: 50 * scale,
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
}

class Frame14 extends StatelessWidget {
  final double scale;
  const Frame14({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10 * scale),
      child: Column(
        children: [
          Text(
            'Sistema de Citas\nMedicas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF0077C2),
              fontSize: 23 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Agenda tu cita médica de manera rápida y sencilla',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15 * scale,
            ),
          ),
        ],
      ),
    );
  }
}

class AgendaCard extends StatelessWidget {
  final String correo;
  final String password;
  final double scale;

  const AgendaCard({super.key, required this.correo, required this.password, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5 * scale, offset: Offset(0, 2 * scale))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFF0077C2),
              shape: BoxShape.circle,
            ),
            child: Center(child: Image.asset('img/Imagen3.png', width: 35 * scale, height: 35 * scale)),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Agenda tu cita',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Selecciona la fecha y hora que mejor se adapte a tu disponibilidad',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleCita1(correo: correo, password: password),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5 * scale)),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
              child: Text(
                'Agendar cita',
                style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HistorialCard extends StatelessWidget {
  final String correo;
  final String password;
  final double scale;

  const HistorialCard({super.key, required this.correo, required this.password, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5 * scale, offset: Offset(0, 2 * scale))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFF0077C2),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(Icons.history, color: Colors.white, size: 30 * scale)),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Historial de citas',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Consulta el historial de tus citas anteriores',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistorialCitas(correo: correo, password: password),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5 * scale)),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
              child: Text(
                'Ver historial',
                style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DatosClinicosCard extends StatelessWidget {
  final String correo;
  final String password;
  final String? clavePaciente; // 🔹 Nuevo parámetro opcional
  final double scale;

  const DatosClinicosCard({
    super.key,
    required this.correo,
    required this.password,
    required this.scale,
    this.clavePaciente, // 🔹 Se agrega aquí también
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5 * scale, offset: Offset(0, 2 * scale))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50 * scale,
            height: 50 * scale,
            decoration: const BoxDecoration(
              color: Color(0xFF0077C2),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(Icons.favorite, color: Colors.white, size: 30 * scale)),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Datos clínicos',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Consulta o actualiza tu información médica personal',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetalleDatosClinicosPage(
      correo: correo,
      password: password,
      clavePaciente: clavePaciente, // 🔹 aquí la pasas directamente
    ),
  ),
);

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5 * scale)),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
              child: Text(
                'Ver datos clínicos',
                style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
