import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final existingItemIndex = state.items.indexWhere(
      (item) => item.product.id == event.product.id,
    );

    List<CartItem> updatedItems;

    if (existingItemIndex >= 0) {
      final existingItem = state.items[existingItemIndex];
      final newQuantity = existingItem.quantity + event.quantity;

      updatedItems = List.from(state.items);
      updatedItems[existingItemIndex] = existingItem.copyWith(
        quantity: newQuantity,
      );
    } else {
      final newItem = CartItem(
        id: '${event.product.id}-${DateTime.now().millisecondsSinceEpoch}',
        product: event.product,
        quantity: event.quantity,
      );

      updatedItems = List.from(state.items)..add(newItem);
    }

    emit(state.copyWith(items: updatedItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .where((item) => item.id != event.itemId)
        .toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(itemId: event.itemId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(state.copyWith(items: []));
  }
}
