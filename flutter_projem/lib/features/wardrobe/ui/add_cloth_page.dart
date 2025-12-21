import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/image_storage.dart';
import '../../../core/utils/validators.dart';
import '../data/wardrobe_repository.dart';

class AddClothPage extends ConsumerStatefulWidget {
  const AddClothPage({super.key});

  @override
  ConsumerState<AddClothPage> createState() => _AddClothPageState();
}

class _AddClothPageState extends ConsumerState<AddClothPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _colorController = TextEditingController();
  final _tagsController = TextEditingController();
  ClothCategory _category = ClothCategory.top;
  Season _season = Season.all;
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSourceType source) async {
    final storage = ImageStorage();
    final path = await storage.pickAndSaveImage(
      source == ImageSourceType.gallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (path != null) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final repo = ref.read(wardrobeRepositoryProvider);
    await repo.addCloth(
      userId: user.id,
      name: _nameController.text.trim(),
      category: _category,
      season: _season,
      color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
      tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
      imagePath: _imagePath,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kıyafet Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ad'),
                validator: (v) => Validators.required(v, fieldName: 'Ad'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ClothCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(
                    value: ClothCategory.top,
                    child: Text('Üst'),
                  ),
                  DropdownMenuItem(
                    value: ClothCategory.bottom,
                    child: Text('Alt'),
                  ),
                  DropdownMenuItem(
                    value: ClothCategory.shoes,
                    child: Text('Ayakkabı'),
                  ),
                  DropdownMenuItem(
                    value: ClothCategory.outerwear,
                    child: Text('Dış giyim'),
                  ),
                  DropdownMenuItem(
                    value: ClothCategory.accessory,
                    child: Text('Aksesuar'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Season>(
                initialValue: _season,
                decoration: const InputDecoration(labelText: 'Sezon'),
                items: const [
                  DropdownMenuItem(value: Season.summer, child: Text('Yaz')),
                  DropdownMenuItem(value: Season.winter, child: Text('Kış')),
                  DropdownMenuItem(value: Season.all, child: Text('4 Mevsim')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _season = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Renk'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(labelText: 'Etiketler'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSourceType.gallery),
                    icon: const Icon(Icons.photo),
                    label: const Text('Galeriden'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSourceType.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                  ),
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ImageSourceType { gallery, camera }