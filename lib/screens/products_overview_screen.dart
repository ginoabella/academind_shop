import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/widgets/products_grid.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/product-overview';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;
  bool _isInit = true;
  bool _isLoading = false;
  bool _isOnError = false;

  @override
  void didChangeDependencies() {
    _isOnError = false;
    if (_isInit) {
      setState(() => _isLoading = true);

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() => _isLoading = false);
      }).catchError((onError) {
        setState(() => _isLoading = false);
        _isOnError = true;
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isOnError
              ? Center(child: Text('An Error occured'))
              : ProductsGrid(_showOnlyFavorites),
    );
  }
}
