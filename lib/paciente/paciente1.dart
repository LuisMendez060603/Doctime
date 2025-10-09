import 'package:flutter/material.dart';
import 'patient_dialog.dart';
import 'detalle_cita1.dart'; // Pantalla para agendar cita
import 'historial_citas.dart';


class Paciente1 extends StatelessWidget {
  final String correo;
  final String password;

  const Paciente1({Key? key, required this.correo, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth < 450 ? constraints.maxWidth * 0.95 : 420;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(1),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Header(correo: correo, password: password),
                  const SizedBox(height: 20),
                  const Frame14(),
                  const SizedBox(height: 20),
                  AgendaCard(correo: correo, password: password),
                  const SizedBox(height: 15),
                  HistorialCard(correo: correo, password: password),
                  const Spacer(),
                ],
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

  const Header({super.key, required this.correo, required this.password});

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => PatientDialog(correo: correo, password: password),
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
}

class Frame14 extends StatelessWidget {
  const Frame14({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        return Column(
          children: [
            Container(
              width: width,
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    'Sistema de Citas\nMedicas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0077C2),
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Agenda tu cita médica de manera rápida y sencilla',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Euclid Circular A',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AgendaCard extends StatelessWidget {
  final String correo;
  final String password;

  const AgendaCard({super.key, required this.correo, required this.password});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 420 ? 390 : screenWidth * 0.9;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: const Color(0xFF0077C2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'img/Imagen3.png',
                width: 35,
                height: 35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Agenda tu cita',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Selecciona la fecha y hora que mejor se adapte\na tu disponibilidad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(332, 37),
            ),
            child: const Text(
              'Agendar cita',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
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

  const HistorialCard({super.key, required this.correo, required this.password});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 420 ? 390 : screenWidth * 0.9;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: const Color(0xFF0077C2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'img/Imagen3.png', // Asegúrate de tener esta imagen
                width: 30,
                height: 30,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Historial de citas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulta el historial de tus citas anteriores',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(332, 37),
            ),
            child: const Text(
              'Ver historial',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
