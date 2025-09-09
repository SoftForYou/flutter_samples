import 'package:cached_query/cached_query.dart';
import 'package:demo_app/features/product/models/product_model.dart';
import 'package:demo_app/features/product/product_service.dart';

class ProductQueries {
  static const String productsKey = "products";
  static const Duration cacheTime = Duration(minutes: 5);
}

final _productService = ProductService();

Query<List<Product>> getProductsQuery() {
  return Query(
    key: ProductQueries.productsKey,
    queryFn: () async {
      try {
        return await _productService.getProducts();
      } catch (e) {
        throw Exception('Unable to load products. Please try again.');
      }
    },
    config: QueryConfig(cacheDuration: ProductQueries.cacheTime),
  );
}

Query<Product> getProductByIdQuery(int productId) {
  return Query(
    key: "${ProductQueries.productsKey}_$productId",
    queryFn: () async {
      try {
        return await _productService.getProductById(productId);
      } catch (e) {
        throw Exception('Unable to load product details. Please try again.');
      }
    },
    config: QueryConfig(cacheDuration: ProductQueries.cacheTime),
  );
}
