import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/travel_log.dart';
import '../providers/travel_logs_provider.dart';

class EditLogScreen extends ConsumerStatefulWidget {
  final int logId;

  const EditLogScreen({super.key, required this.logId});

  @override
  ConsumerState<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends ConsumerState<EditLogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  DateTime? _selectedDate;
  String? _imagePath;
  double? _latitude;
  double? _longitude;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final logs = ref.read(travelLogsProvider);
      final log = logs.firstWhere(
            (l) => l.id == widget.logId,
        orElse: () => TravelLog(
          id: -1,
          title: '',
          description: '',
          date: DateTime.now(),
          userId: '',
        ),
      );

      if (log.id != -1) {
        _titleController.text = log.title;
        _descriptionController.text = log.description;
        _locationController.text = log.location ?? '';
        _selectedDate = log.date;
        _imagePath = log.imagePath;
        _latitude = log.latitude;
        _longitude = log.longitude;
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await path_provider.getApplicationDocumentsDirectory();
      final fileName = p.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final logs = ref.read(travelLogsProvider);
      final existingLog = logs.firstWhere((l) => l.id == widget.logId);

      final updatedLog = TravelLog(
        id: existingLog.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate ?? existingLog.date,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        imagePath: _imagePath,
        userId: existingLog.userId,
      );

      ref.read(travelLogsProvider.notifier).updateLog(updatedLog);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _selectedDate != null
        ? '${_selectedDate!.day.toString().padLeft(2, '0')}.${_selectedDate!.month.toString().padLeft(2, '0')}.${_selectedDate!.year} r.'
        : 'Wybierz datę';

    final hasImage = _imagePath != null &&
        _imagePath!.isNotEmpty &&
        File(_imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj wpis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Zapisz zmiany',
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withAlpha(120),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: hasImage
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(_imagePath!), fit: BoxFit.cover),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white),
                              onPressed: _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text('Zmień lub dodaj zdjęcie'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tytuł podróży',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wpisz tytuł podróży';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Miejscowość / Kraj',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_month),
                title: const Text('Data wyjazdu'),
                subtitle: Text(formattedDate),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Opis i wspomnienia',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Wpisz opis podróży';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Zapisz Zmiany'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}