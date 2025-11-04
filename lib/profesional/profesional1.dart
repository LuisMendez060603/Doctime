import 'package:flutter/material.dart';
import 'patient_dialog1.dart';
import 'citas_page.dart';
import 'lista_pacientes.dart';

class Profesional1 extends StatelessWidget {
  final String correo;
  final String password;

  const Profesional1({Key? key, required this.correo, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Escala basada en ancho de ventana (400 es ancho base)
        double scale = constraints.maxWidth / 400;
        scale = scale < 0.8 ? 0.8 : scale; // mínimo
        scale = scale > 1.5 ? 1.5 : scale; // máximo

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
                    SizedBox(height: 20 * scale),
                    OtroCard(correo: correo, password: password, scale: scale),
                    SizedBox(height: 20 * scale),
                  ],
                ),
              ),
            ),
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
              builder: (context) => PatientDialog1(correo: correo, password: password),
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
              fontSize: 24 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Administra tus consultas médicas de forma eficiente y organizada.',
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
            'Citas Agendadas',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Consulta las citas programadas por los pacientes y administra tu agenda médica.',
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
                    builder: (context) => CitasPage(correo: correo, password: password),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5 * scale)),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
              child: Text(
                'Ver Citas',
                style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtroCard extends StatelessWidget {
  final String correo;
  final String password;
  final double scale;

  const OtroCard({super.key, required this.correo, required this.password, required this.scale});

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
            'Pacientes Registrados',
            style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'Consulta y gestiona la lista de pacientes registrados en el sistema.',
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
                    builder: (context) => ListaPacientesPage(correo: correo, password: password),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5 * scale)),
                padding: EdgeInsets.symmetric(vertical: 12 * scale),
              ),
              child: Text(
                'Ver Pacientes',
                style: TextStyle(fontSize: 15 * scale, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
