class MangaItem {
  final int id;
  final String imagePath;
  final String title;
  final String description;
  final String price;
  final List<String> additionalImages;
  final String format;
  final String publisher;
  final String shortDescription;
  final String chapters;

  MangaItem({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.price,
    required this.additionalImages,
    required this.format,
    required this.publisher,
    required this.shortDescription,
    required this.chapters,
  });

  factory MangaItem.fromJson(Map<String, dynamic> json) {
    return MangaItem(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      additionalImages: List<String>.from(json['additional_images'] ?? []),
      format: json['format'] ?? '',
      publisher: json['publisher'] ?? '',
      shortDescription: json['short_description'] ?? '',
      chapters: json['chapters'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'title': title,
      'description': description,
      'price': price,
      'additional_images': additionalImages,
      'format': format,
      'publisher': publisher,
      'short_description': shortDescription,
      'chapters': chapters,
    };
  }
}
