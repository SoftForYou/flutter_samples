import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';
import '../../../router.dart';

class CartIconWithBadge extends StatelessWidget {
  const CartIconWithBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        return Stack(
          children: [
            IconButton(
              icon: Badge(
                isLabelVisible: state.totalItems > 0,
                largeSize: 18,
                smallSize: 14,
                label: Text(
                  '${state.totalItems}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                child: Icon(Icons.shopping_cart),
              ),
              color: Colors.black,
              onPressed: () {
                context.push(AppRoutes.cart);
              },
            ),
          ],
        );
      },
    );
  }
}
