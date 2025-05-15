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
                  AgendaCard(correo: correo, password: password), // Tarjeta original
                  const SizedBox(height: 20),
                  OtroCard(correo: correo, password: password), // Nueva tarjeta añadida
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
                    image: AssetImage("img/Imagen1.png"),
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
                        color: Colors.blue,
                        fontSize: 14,
                        fontFamily: 'Euclid Circular A',
                      ),
                    ),
                    Text(
                      'Consultas y citas médicas',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontFamily: 'Inter',
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
                      color: Colors.lightBlueAccent,
                      fontSize: 24,
                      fontFamily: 'Euclid Circular A',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Administra tus consultas médicas de forma eficiente y organizada.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[600],
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
              color: Color(0xFF00ADFF),
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
            'Citas Agendadas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulta las citas programadas por los pacientes y administra tu agenda médica.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitasPage(correo: correo, password: password),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ADFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(332, 37),
            ),
            child: const Text(
              'Ver Citas',
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

class OtroCard extends StatelessWidget {
  final String correo;
  final String password;

  const OtroCard({super.key, required this.correo, required this.password});

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
              color: Color(0xFF00ADFF),
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
            'Pacientes Registrados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulta y gestiona la lista de pacientes registrados en el sistema.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListaPacientesPage(correo: correo, password: password),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00ADFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: const Size(332, 37),
            ),
            child: const Text(
              'Ver Pacientes',
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

