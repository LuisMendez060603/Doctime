import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sesion.dart'; // Ajusta la ruta según tu estructura

class ConfirmarCorreoPage extends StatefulWidget {
  final String correo;
  const ConfirmarCorreoPage({super.key, required this.correo});

  @override
  _ConfirmarCorreoPageState createState() => _ConfirmarCorreoPageState();
}

class _ConfirmarCorreoPageState extends State<ConfirmarCorreoPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (i) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (i) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  final Color _primary = const Color(0xFF0077C2);

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    final codigo = _controllers.map((e) => e.text).join();
    if (codigo.length != 6) {
      _showWarningDialog("Ingresa los 6 dígitos del código");
      return;
    }

    setState(() => _isLoading = true);
    final url = Uri.parse('http://localhost/doctime/BD/verificar_codigo.php');

    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"correo": widget.correo, "codigo": codigo}));
      final data = jsonDecode(resp.body);
      if (data["success"] == true || data["estado"] == "ok") {
        _showSuccessDialog("¡Cuenta verificada correctamente!");
      } else {
        _showWarningDialog(data["message"] ?? "Código incorrecto");
      }
    } catch (e) {
      _showWarningDialog("Error de conexión: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _isResending = true);
    final url = Uri.parse('http://localhost/doctime/BD/registrar.php');

    try {
      final resp = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"reenviar": true, "correo": widget.correo}));
      final data = jsonDecode(resp.body);
      if (data["success"] == true) {
        _showWarningDialog(data["message"] ?? "Código reenviado");
      } else {
        _showWarningDialog(data["message"] ?? "Error al reenviar el código");
      }
    } catch (e) {
      _showWarningDialog("Error de conexión: $e");
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _showSuccessDialog(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              const Text(
                '¡Registro exitoso!',
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
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const IniciarSesionPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                mensaje,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePaste(int index, String value) {
    if (value.length > 1) {
      final chars = value.replaceAll(RegExp(r'\s+'), '').split('');
      for (int i = 0; i < chars.length && index + i < 6; i++) {
        _controllers[index + i].text = chars[i];
      }
      final next = index + chars.length;
      if (next < 6) _focusNodes[next].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 500 ? 480.0 : width - 40;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FB),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Image.asset(
                    "img/logo.png",
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'DocTime',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'Consultas y citas médicas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xDD000000), // negro con 87% de opacidad (~black87)
                      fontWeight: FontWeight.w500, // un poco más gruesa que normal
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔹 Cuadro azul mejorado con bordes redondeados
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primary, _primary.withOpacity(0.9)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.mark_email_unread,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Verifica tu correo",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Introduce el código enviado",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  // Cuerpo principal
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 22),
                    child: Column(
                      children: [
                        Text(
                          "Código enviado a ${widget.correo}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 18),

                        // Inputs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 52,
                              height: 64,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: _primary.withOpacity(0.9),
                                        width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: _primary, width: 3),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    if (index > 0)
                                      _focusNodes[index - 1].requestFocus();
                                  } else {
                                    if (value.length > 1) {
                                      _handlePaste(index, value);
                                    } else {
                                      if (index < 5)
                                        _focusNodes[index + 1].requestFocus();
                                    }
                                  }
                                },
                                onSubmitted: (_) {
                                  if (index == 5) _verificarCodigo();
                                },
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading ? null : _verificarCodigo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        "Verificar",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        TextButton.icon(
                          onPressed: _isResending ? null : _reenviarCodigo,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : Icon(Icons.refresh, color: _primary),
                          label: Text("Reenviar código",
                              style: TextStyle(color: _primary)),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
