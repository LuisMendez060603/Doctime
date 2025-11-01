import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfGenerator {
  // --- CONSTANTES DE ESTILO ---
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF007bff); // Azul de marca
  static const PdfColor headerBgColor = PdfColor.fromInt(0xFFf0f0f0); // Gris muy claro para fondos

  static Future<void> generarPDF(
    BuildContext context,
    Map<String, dynamic> cita,
    Map<String, dynamic>? consulta,
  ) async {
    final pdf = pw.Document();

    // 🔹 Cargar fuentes
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData);

    // 🔹 Crear página PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (contextPdf) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. ENCABEZADO Y TÍTULO
              pw.Container(
                alignment: pw.Alignment.centerRight,
                // Puedes agregar un pw.Image.asset() si tienes un logo.
                child: pw.Text('doctime', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700, font: ttf)),
              ),
              pw.Text(
                'Detalle de la Cita',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  font: boldTtf,
                ),
              ),
              pw.Divider(color: primaryColor, thickness: 2), 
              pw.SizedBox(height: 15),

              // 2. DETALLE DE LA CITA (ESTILO TARJETA)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: headerBgColor, 
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Fecha:', cita['fecha'], ttf, boldTtf),
                    _buildDetailRow('Hora:', cita['hora'], ttf, boldTtf),
                    _buildDetailRow('Profesional:', cita['profesional'], ttf, boldTtf),
                    
                  ],
                ),
              ),
              pw.SizedBox(height: 25),

              // 3. DATOS DE LA CONSULTA
              pw.Text(
                'Datos de la Consulta',
                style: pw.TextStyle(
                  fontSize: 20, 
                  fontWeight: pw.FontWeight.bold, 
                  font: boldTtf,
                ),
              ),
              pw.SizedBox(height: 10),

              if (consulta != null) ...[
                // Síntomas
                _buildConsultBlock('Síntomas:', consulta['sintomas'], ttf, boldTtf, headerBgColor),
                pw.SizedBox(height: 15),

                // Diagnóstico
                _buildConsultBlock('Diagnóstico:', consulta['diagnostico'], ttf, boldTtf, headerBgColor),
                pw.SizedBox(height: 15),

                // Tratamiento
                _buildConsultBlock('Tratamiento:', consulta['tratamiento'], ttf, boldTtf, headerBgColor),
              ] else
                pw.Text('No hay datos de consulta para esta cita', style: pw.TextStyle(font: ttf)),
            ],
          );
        },
      ),
    );

    // --- LÓGICA DE GUARDADO (SIN CAMBIOS) ---
    Directory? directory;

    if (kIsWeb) {
      print("Descarga directa no soportada en web.");
      return;
    }

    // Lógica para obtener el directorio de descargas
    if (Platform.isWindows) {
      directory = await getDownloadsDirectory(); 
    } else if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Permiso de almacenamiento denegado");
        return;
      }
      // Directorio de Descargas en Android (puede variar según la versión)
      directory = Directory('/storage/emulated/0/Download'); 
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Guardar PDF con nombre incremental
    final downloadPath = directory!.path;
    String baseName = "doctime_cita";
    String fileName = "$baseName.pdf";
    int counter = 1;

    while (File('$downloadPath/$fileName').existsSync()) {
      fileName = "$baseName$counter.pdf";
      counter++;
    }

    final file = File('$downloadPath/$fileName');
    await file.writeAsBytes(await pdf.save());

    print('PDF guardado en: ${file.path}');

    // Mostrar diálogo de éxito
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (contextDialog) => AlertDialog(
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.check_circle, color: Colors.green, size: 60), 
                const SizedBox(height: 10),
                const Text(
                  '¡PDF descargado con éxito!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Guardado como: $fileName',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                child: const Text('Aceptar'),
                onPressed: () => Navigator.of(contextDialog).pop(),
              ),
            ),
          ],
        ),
      );
    }
  }

  // --- WIDGETS AUXILIARES PARA EL DISEÑO PDF ---
  
  // Fila para los detalles de la cita (Etiqueta: Valor)
  static pw.Widget _buildDetailRow(
    String label, 
    String value, 
    pw.Font regularFont, 
    pw.Font boldFont, {
    bool isHighlight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100, // Ancho fijo para la etiqueta
            child: pw.Text(
              label, 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: boldFont, fontSize: 11),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value, 
              style: pw.TextStyle(
                font: regularFont, 
                fontSize: 11,
                color: isHighlight ? primaryColor : PdfColors.black, // Usar primaryColor para destacar
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bloque para Síntomas, Diagnóstico y Tratamiento
  static pw.Widget _buildConsultBlock(
    String title,
    String content,
    pw.Font regularFont,
    pw.Font boldFont,
    PdfColor headerBgColor,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1), // Borde sutil
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título del bloque con color de fondo
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: headerBgColor, 
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(4), 
                topRight: pw.Radius.circular(4),
              ),
            ),
            child: pw.Text(
              title, 
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, 
                font: boldFont, 
                fontSize: 12,
                color: PdfColors.black,
              ),
            ),
          ),
          // Contenido con padding
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Text(
              content, 
              style: pw.TextStyle(font: regularFont, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}