import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/providers/orders.dart' show Orders;
import 'package:shop/widgets/order_item.dart';
import 'package:shop/widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: ListView.builder(
        itemCount: orderData.orders.length,
        itemBuilder: (context, index) => OrderItem(orderData.orders[index]),
      ),
      drawer: AppDrawer(),
    );
  }
}
