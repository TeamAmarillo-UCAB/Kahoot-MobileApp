// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

// --- Importaciones de tu Arquitectura (RUTAS CORREGIDAS SIN PREFIJO DE PAQUETE) ---
// Ahora las rutas son absolutas dentro del paquete: /Contenido_Multimedia/...

// 1. Dominio (Entidades e Interfaces de Contrato)
import 'Contenido_Multimedia/domain/entities/media_file.dart';
import 'Contenido_Multimedia/domain/repositories/image_repository.dart';
import 'Contenido_Multimedia/domain/datasource/image_datasource.dart';

// 2. Aplicación (Casos de Uso)
import 'Contenido_Multimedia/application/usecases/upload_image.dart'; // Contiene la clase UploadImage

// 3. Infraestructura (Implementaciones de Repositorio y Datasource)
import 'Contenido_Multimedia/infrastructure/repositories/image_repository_impl.dart';
import 'Contenido_Multimedia/infrastructure/datasource/image_datasource_impl.dart';

// -------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// -------------------------------------------------------------
// CLASES MYAPP Y MYHOMEPAGE
// -------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. Declaración de las dependencias
  late final ImageDataSource _dataSource;
  late final ImageRepository _repository;
  late final UploadImage _uploadImageUseCase;

  String _uploadStatus = 'Pulsa el botón de subida (➕) para probar.';

  @override
  void initState() {
    super.initState();
    // 2. Inicialización de la cadena de dependencias
    _dataSource = ImageDatasourceImpl();
    _repository = ImageRepositoryImpl(_dataSource);
    _uploadImageUseCase = UploadImage(_repository);
  }

  // Función de prueba que simula la selección y la subida
  Future<void> _testUpload() async {
    setState(() {
      _uploadStatus = 'Seleccionando archivo...';
    });

    try {
      // 3. Selección del archivo y obtención de bytes (Capa de Presentación/Plataforma)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _uploadStatus = 'Subida cancelada por el usuario.');
        return;
      }

      PlatformFile platformFile = result.files.first;
      Uint8List? fileBytes = platformFile.bytes;

      if (fileBytes == null || fileBytes.isEmpty) {
        setState(() => _uploadStatus = 'Error: No se pudieron leer los bytes.');
        return;
      }

      // 4. Creación de la Entidad de Dominio MediaFile
      final MediaFile fileToUpload = MediaFile(
        bytes: fileBytes.toList(),
        name: platformFile.name,
        mimeType: platformFile.extension != null
            ? 'image/${platformFile.extension}'
            : null,
      );

      setState(() {
        _uploadStatus = 'Subiendo ${fileToUpload.name}...';
      });

      // 5. Ejecución del Caso de Uso
      final responseData = await _uploadImageUseCase.call(fileToUpload);

      // 6. Manejo de la respuesta
      setState(() {
        _uploadStatus = '✅ ¡Subida exitosa! UUID: ${responseData['id']}';
      });
    } catch (e) {
      // Manejo de errores de red, API, o validación
      setState(() {
        _uploadStatus = '❌ Error de subida: ${e.toString()}';
      });
      print('ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Estado de la Prueba de Subida:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _uploadStatus,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testUpload,
        tooltip: 'Subir Imagen de Prueba',
        child: const Icon(Icons.upload),
      ),
    );
  }
}
