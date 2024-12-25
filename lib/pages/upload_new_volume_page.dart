import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/manga_item.dart';
import '../services/api_service.dart';

// Константы для цветов и размеров
const Color primaryColor = Color(0xFFC84B31);
const Color secondaryColor = Color(0xFFECDBBA);
const Color textColor = Color(0xFF56423D);
const Color backgroundColor = Color(0xFF191919);

class UploadNewVolumePage extends StatefulWidget {
  final ValueChanged<MangaItem?> onItemCreated;

  const UploadNewVolumePage({Key? key, required this.onItemCreated}) : super(key: key);

  @override
  _UploadNewVolumePageState createState() => _UploadNewVolumePageState();
}

class _UploadNewVolumePageState extends State<UploadNewVolumePage> {
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _chaptersController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  final TextEditingController _fullDescriptionController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();
  final TextEditingController _publisherController = TextEditingController();
  final List<String> _imageLinks = [];
  bool _isSubmitting = false;

  final List<String> formatTexts = [
    'Твердый переплет\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
    'Мягкий переплет\nФормат издания 18.0 x 11.0 см\nкол-во стр от 350 до 370',
    'Электронная версия\nФормат издания 19.6 x 12.5 см\nкол-во стр от 380 до 400',
  ];

  final List<String> publisherTexts = [
    'Издательство Терлецки Комикс',
    'Издательство Другое Комикс',
    'Издательство Еще Комикс',
    'Alt Graph',
  ];

  void _addImage() {
    if (_imageLinks.length < 3) {
      showDialog(
        context: context,
        builder: (context) {
          TextEditingController _urlController = TextEditingController();
          return AlertDialog(
            title: const Text("Добавить изображение"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: "Введите ссылку на изображение"),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Пример ссылки: https://example.com/image.jpg",
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String url = _urlController.text.trim();
                  if (url.isNotEmpty && url.startsWith("http")) {
                    setState(() {
                      _imageLinks.add(url);
                      Navigator.of(context).pop();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Введите корректную ссылку на изображение")),
                    );
                  }
                },
                child: const Text("Добавить"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Отмена"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Максимум 3 изображения")),
      );
    }
  }

  bool _validateInputs() {
    return _volumeController.text.isNotEmpty &&
           _chaptersController.text.isNotEmpty &&
           _priceController.text.isNotEmpty &&
           _shortDescriptionController.text.isNotEmpty &&
           _fullDescriptionController.text.isNotEmpty &&
           _formatController.text.isNotEmpty &&
           _publisherController.text.isNotEmpty &&
           _imageLinks.length == 3;
  }

  Future<void> _submit() async {
    if (_validateInputs()) {
      setState(() => _isSubmitting = true);
      final newMangaItem = MangaItem(
        id: 0, 
        imagePath: _imageLinks[0],
        title: _volumeController.text,
        description: _fullDescriptionController.text,
        price: _priceController.text,
        additionalImages: _imageLinks.sublist(1),
        format: _formatController.text,
        publisher: _publisherController.text,
        shortDescription: _shortDescriptionController.text, 
        chapters: _chaptersController.text, 
      );

      try {
        final existingProducts = await ApiService().fetchProducts();
        if (existingProducts.any((product) => product.title == newMangaItem.title)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Товар с таким названием уже существует")),
          );
          return;
        }

        final createdItem = await ApiService().createProduct(newMangaItem);
        widget.onItemCreated(createdItem);
        Navigator.pop(context, createdItem);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании товара: $error')),
        );
      } finally {
        setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Пожалуйста, заполните все поля и добавьте ровно 3 изображения")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Добавить новый том"),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "MANgo100+",
                      style: TextStyle(color: primaryColor, fontSize: 36, fontFamily: 'Russo One'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    _buildInputField('Какой том', _volumeController, hintText: 'Например, Том 1'),
                    const SizedBox(height: 15),
                    _buildInputField('Главы', _chaptersController, hintText: 'Например, № глав: 1-36 + дополнительные истории'),
                    const SizedBox(height: 15),
                    _buildInputField('Цена', _priceController, hintText: 'Например, 100 рублей', keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildDropdownField('Формат издания', _formatController, formatTexts),
                    const SizedBox(height: 15),
                    _buildDropdownField('Издательство', _publisherController, publisherTexts),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Expanded(
                          child: Text("Добавить изображения", style: TextStyle(color: primaryColor)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: secondaryColor),
                          onPressed: _addImage,
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _imageLinks.length,
                      itemBuilder: (context, index) => Row(
                        children: [
                          Text(
                            "Изображение ${index + 1}",
                            style: TextStyle(color: index == 0 ? primaryColor : textColor),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() => _imageLinks.removeAt(index)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildTextArea('Краткое описание', _shortDescriptionController, hintText: 'Описание в нескольких строках...'),
                    const SizedBox(height: 15),
                    _buildTextArea('Полное описание', _fullDescriptionController, hintText: 'Детальное описание...'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        "Опубликовать",
                        style: TextStyle(color: secondaryColor, fontSize: isMobile ? 16.0 : 20.0),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {String hintText = '', TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> options) {
    return DropdownButtonFormField<String>(
      value: options.contains(controller.text) ? controller.text : null,
      items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
      onChanged: (value) => setState(() => controller.text = value ?? ''),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Widget _buildTextArea(String label, TextEditingController controller, {String hintText = ''}) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: secondaryColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _chaptersController.dispose();
    _priceController.dispose();
    _shortDescriptionController.dispose();
    _fullDescriptionController.dispose();
    _formatController.dispose();
    _publisherController.dispose();
    super.dispose();
  }
}
