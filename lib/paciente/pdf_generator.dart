import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class PdfGenerator {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF007bff);
  static const PdfColor headerBgColor = PdfColor.fromInt(0xFFf0f0f0);

  static Future<void> generarPDF(
    BuildContext context,
    Map<String, dynamic> cita,
    Map<String, dynamic>? consulta,
  ) async {
    final pdf = pw.Document();

    // Cargar fuentes
    final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);
    final boldFontData = await rootBundle.load("assets/fonts/Roboto-Bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData);

    // --- CREAR PDF ---
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (contextPdf) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'doctime',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                  font: ttf,
                ),
              ),
            ),
            pw.Text(
              'Detalle de la Cita',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                font: boldTtf,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: primaryColor, thickness: 2),
            pw.SizedBox(height: 10),
          ],
        ),
        footer: (contextPdf) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Página ${contextPdf.pageNumber}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              font: ttf,
            ),
          ),
        ),
        build: (contextPdf) {
          List<pw.Widget> content = [];

          // DETALLE DE LA CITA
          content.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: headerBgColor,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (consulta != null && consulta['nombre_paciente'] != null)
                    _buildDetailRow('Paciente:', consulta['nombre_paciente'], ttf, boldTtf),
                  _buildDetailRow('Fecha:', cita['fecha'], ttf, boldTtf),
                  _buildDetailRow('Hora:', cita['hora'], ttf, boldTtf),
                  _buildDetailRow(
                    'Profesional:',
                    consulta != null && consulta['nombre_profesional'] != null
                        ? consulta['nombre_profesional']
                        : 'No especificado',
                    ttf,
                    boldTtf,
                  ),
                ],
              ),
            ),
          );

          content.add(pw.SizedBox(height: 25));

          // DATOS DE LA CONSULTA
          content.add(
            pw.Text(
              'Datos de la Consulta',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                font: boldTtf,
              ),
            ),
          );
          content.add(pw.SizedBox(height: 10));

          if (consulta != null) {
            content.addAll([
              _buildKeepTogetherBlock('Síntomas:', consulta['sintomas'], ttf, boldTtf, headerBgColor),
              pw.SizedBox(height: 15),
              _buildKeepTogetherBlock('Diagnóstico:', consulta['diagnostico'], ttf, boldTtf, headerBgColor),
              pw.SizedBox(height: 15),
              _buildKeepTogetherBlock('Tratamiento:', consulta['tratamiento'], ttf, boldTtf, headerBgColor),
            ]);
          } else {
            content.add(
              pw.Text(
                'No hay datos de consulta para esta cita',
                style: pw.TextStyle(font: ttf),
              ),
            );
          }

          return content;
        },
      ),
    );

    // --- GUARDAR PDF ---
    Directory? directory;
    if (kIsWeb) return;

    if (Platform.isWindows) {
      directory = await getDownloadsDirectory();
    } else if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) return;
      directory = Directory('/storage/emulated/0/Download');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  // ---- MÉTODOS AUXILIARES ----

  static pw.Widget _buildDetailRow(String label, String value, pw.Font regularFont, pw.Font boldFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: boldFont,
                fontSize: 11,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: regularFont, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildKeepTogetherBlock(String title, String content, pw.Font regularFont, pw.Font boldFont, PdfColor headerBgColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300, width: 1),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  content,
                  style: pw.TextStyle(font: regularFont, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
