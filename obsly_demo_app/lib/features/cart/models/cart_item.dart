import 'package:equatable/equatable.dart';
import '../../product/models/product_model.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final String id;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.id,
  });

  CartItem copyWith({Product? product, int? quantity, String? id}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      id: id ?? this.id,
    );
  }

  double get totalPrice => (product.price * quantity).toDouble();

  @override
  List<Object?> get props => [product, quantity, id];
}
