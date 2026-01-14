import 'package:flutter/material.dart';
import '../../../../Contenido_Multimedia/domain/entities/media_resource.dart';
import '../../../../Contenido_Multimedia/domain/repositories/media_resource_repository.dart';
import '../../../../Contenido_Multimedia/domain/datasource/media_resource_datasource.dart';
import '../../../../Contenido_Multimedia/application/usecases/upload_media_resource.dart';
import '../../../../Contenido_Multimedia/infrastructure/repositories/media_resource_repository_impl.dart';
import '../../../../Contenido_Multimedia/infrastructure/datasource/media_resource_datasource_impl.dart';
import '../../../../Contenido_Multimedia/infrastructure/services/file_picker_service.dart';

class MediaResourceSelector extends StatefulWidget {
  final Function(String assetId)? onIdSelected;

  const MediaResourceSelector({super.key, this.onIdSelected});

  @override
  State<MediaResourceSelector> createState() => _MediaResourceSelectorState();
}

class _MediaResourceSelectorState extends State<MediaResourceSelector> {
  late final MediaResourceDataSource _dataSource;
  late final MediaResourceRepository _repository;
  late final UploadMediaResource _uploadMediaResourceUseCase;
  late final FilePickerService _filePickerService;

  String _statusMessage = '';
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _dataSource = MediaResourceDatasourceImpl();
    _repository = MediaResourceRepositoryImpl(_dataSource);
    _uploadMediaResourceUseCase = UploadMediaResource(_repository);
    _filePickerService = FilePickerServiceImpl();
  }

  Future<void> _handleUpload() async {
    setState(() {
      _statusMessage = 'Seleccionando archivo...';
      _previewUrl = null;
    });

    try {
      final fileToUpload = await _filePickerService.pickImageResource();
      if (fileToUpload == null) {
        setState(() => _statusMessage = '');
        return;
      }

      setState(() => _statusMessage = 'Subiendo...');

      final responseData = await _uploadMediaResourceUseCase.call(fileToUpload);

      final uploadedId = responseData['assetId'] as String;
      final imageUrl = responseData['url'] as String;

      setState(() {
        _previewUrl = imageUrl;
        _statusMessage = '';
      });

      if (widget.onIdSelected != null) {
        widget.onIdSelected!(uploadedId);
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_previewUrl != null)
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(
                  _previewUrl!,
                  height: 150,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                Positioned(
                  top: -20,
                  right: -20,
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                    ),
                    onPressed: _handleUpload,
                  ),
                ),
              ],
            )
          else ...[
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white70),
              ),
            if (_statusMessage != 'Subiendo...')
              IconButton(
                icon: const Icon(Icons.cloud_upload, color: Color(0xFFFFD54F)),
                iconSize: 48,
                onPressed: _handleUpload,
              ),
            if (_statusMessage == 'Subiendo...')
              const CircularProgressIndicator(color: Color(0xFFFFD54F)),
          ],
        ],
      ),
    );
  }
}
