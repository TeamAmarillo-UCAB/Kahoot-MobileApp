import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../../../Contenido_Multimedia/domain/entities/media_resource.dart';

abstract class FilePickerService {
  Future<MediaResource?> pickImageResource();
}

class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<MediaResource?> pickImageResource() async {
    //Selección del archivo
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
      withData: true,
    );
    //Subida cancelada
    if (result == null || result.files.isEmpty) {
      return null;
    }

    PlatformFile platformFile = result.files.first;
    Uint8List? fileBytes = platformFile.bytes;

    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception(
        'Error: No se pudieron leer los bytes del archivo seleccionado.',
      );
    }

    // Conversión a MediaResource
    final MediaResource fileToUpload = MediaResource(
      bytes: fileBytes.toList(),
      name: platformFile.name,
      mimeType: platformFile.extension != null
          ? 'image/${platformFile.extension}'
          : null,
    );
    //Retorna el archivo como MediaResource
    return fileToUpload;
  }
}
