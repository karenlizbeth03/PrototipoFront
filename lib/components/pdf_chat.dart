import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PDFChat extends StatefulWidget {
  @override
  _PDFChatState createState() => _PDFChatState();
}

class _PDFChatState extends State<PDFChat> {
  String question = '';
  String answer = '';
  bool loading = false;
  bool pdfLoaded = false;

  Future<void> handleFileUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      try {
        // Enviar archivo al backend
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3001/upload-pdf'),
        );
        request.files.add(await http.MultipartFile.fromPath('pdf', file.path));
        var response = await request.send();

        if (response.statusCode == 200) {
          setState(() {
            pdfLoaded = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF cargado y analizado correctamente ✅')),
          );
        } else {
          throw Exception("Error en el servidor");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al leer el PDF ❌')),
        );
        print(e);
      }
    }
  }

  Future<void> handleAsk() async {
    setState(() => loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/ask'),
        headers: {'Content-Type': 'application/json'},
        body: '{"question": "$question"}',
      );

      if (response.statusCode == 200) {
        setState(() {
          answer = response.body;
        });
      } else {
        setState(() {
          answer = 'Error del servidor al obtener respuesta.';
        });
      }
    } catch (e) {
      setState(() {
        answer = 'Error al conectarse al servidor.';
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: handleFileUpload,
            child: Text('Seleccionar PDF'),
          ),
          if (pdfLoaded) ...[
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Escribe tu pregunta...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => question = value),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: loading ? null : handleAsk,
              child: Text(loading ? 'Cargando...' : 'Preguntar'),
            ),
          ],
          if (answer.isNotEmpty) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Respuesta:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(answer),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
