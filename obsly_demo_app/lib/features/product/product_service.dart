import 'package:demo_app/core/api_client.dart';
import 'package:demo_app/features/product/models/product_model.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<Product>> getProducts() async {
    try {
      final response = await _apiClient.get<List<dynamic>>('/products');
      return response.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/products/$id',
      );
      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product with id $id: $e');
    }
  }
}
