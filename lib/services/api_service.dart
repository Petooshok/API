import 'package:dio/dio.dart';
import '../models/manga_item.dart';

class ApiService {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8080';

  Future<List<MangaItem>> fetchProducts() async {
    try {
      final response = await _dio.get('$baseUrl/mangaItems');
      if (response.statusCode == 200) {
        List<MangaItem> products = (response.data as List)
            .map((item) => MangaItem.fromJson(item))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Error fetching products: $e');
    }
  }

  Future<MangaItem> createProduct(MangaItem item) async {
    try {
      final response = await _dio.post(
        '$baseUrl/mangaItems/create',
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Created new MangaItem: ${response.data}");
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error creating product: $e');
      throw Exception('Error creating product: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/mangaItems/delete/$id');
      if (response.statusCode == 204) {
        print("Deleted MangaItem with ID: $id");
      } else if (response.statusCode == 404) {
        throw Exception('Product not found: ${response.statusCode} - ${response.data}');
      } else {
        throw Exception('Failed to delete product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  Future<MangaItem> updateProduct(MangaItem item) async {
    try {
      final response = await _dio.put(
        '$baseUrl/mangaItems/update/${item.id}',
        data: item.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        print("Updated MangaItem with ID: ${item.id}");
        return MangaItem.fromJson(response.data);
      } else {
        throw Exception('Failed to update product: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }
}
