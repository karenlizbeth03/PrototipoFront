import 'dart:convert'; // <-- NECESARIO para jsonDecode
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FilePickerButton extends StatefulWidget {
  final Function(String text, String fileName) onExtractText;
  final bool? resetSignal;

  const FilePickerButton({
    required this.onExtractText,
    this.resetSignal,
    Key? key,
  }) : super(key: key);

  @override
  State<FilePickerButton> createState() => _FilePickerButtonState();
}

class _FilePickerButtonState extends State<FilePickerButton> {
  bool loading = false;

  @override
  void didUpdateWidget(covariant FilePickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.resetSignal == true) {
      // No selectedFileName anymore, así que no hay nada que limpiar visualmente aquí.
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = result.files.single;
      final fileName = file.name;

      if (file.extension?.toLowerCase() != 'pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solo se permiten archivos PDF")),
        );
        return;
      }

      setState(() {
        loading = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backendpdf-production-57c7.up.railway.app/upload-pdf'),
      );

      try {
        print('Nombre del archivo: $fileName');
        print('Modo Web: $kIsWeb');

        if (kIsWeb) {
          if (file.bytes == null) {
            widget.onExtractText('El archivo no tiene contenido.', fileName);
            return;
          }

          request.files.add(
            http.MultipartFile.fromBytes(
              'pdf',
              file.bytes!,
              filename: fileName,
              contentType: MediaType('application', 'pdf'),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pdf',
              file.path!,
              contentType: MediaType('application', 'pdf'),
            ),
          );
        }

        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final decoded = json.decode(responseData.body);
          widget.onExtractText(
            decoded['text'],
            fileName,
          ); // 👈 Usamos el campo correcto
        } else {
          widget.onExtractText('Error al procesar el archivo PDF.', fileName);
        }
      } catch (e) {
        print("Error: $e");
        widget.onExtractText('Error de red.', fileName);
      } finally {
        if (mounted) {
          setState(() => loading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: loading ? null : pickFile,
        ),
        if (loading)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
