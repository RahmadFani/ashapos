import 'package:ashapos/blocs/cart/cart_cubit.dart';
import 'package:ashapos/blocs/categories_food/categories_food_cubit.dart';
import 'package:ashapos/blocs/connectivity/connectivity_cubit.dart';
import 'package:ashapos/blocs/foods/foods_cubit.dart';
import 'package:ashapos/models/categories_food.dart';
import 'package:ashapos/models/food.dart';
import 'package:ashapos/ui/screens/cart/bottom_cart.dart';
import 'package:ashapos/ui/screens/cart/cart.dart';
import 'package:ashapos/ui/screens/cart/select_item.dart';
import 'package:authentication_repository/helpers/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesPage extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute(builder: (_) => SalesPage());
  }

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(builder: (_, state) {
      bool hasselect = state.onselect != null;
      bool hascart = state.carts.length > 0;
      return BlocBuilder<CategoriesFoodCubit, CategoriesFoodState>(
        builder: (_, scate) {
          if (scate.isinitial) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Tambah Penjualan'),
              ),
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }
          return DefaultTabController(
            initialIndex: 0,
            length: scate.categories.length,
            child: WillPopScope(
              onWillPop: () async {
                BlocProvider.of<CartCubit>(context).unselectitem();
                return true;
              },
              child: Scaffold(
                appBar: AppBar(
                    title: Text('Tambah Penjualan'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            BlocProvider.of<CartCubit>(context).unselectitem();
                            Navigator.push(context, CartPage.route());
                          },
                          child: Text(
                            'CHECKOUT',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                    bottom: TabBar(
                        tabs: List.generate(
                            scate.categories.length,
                            (index) => Tab(
                                  text: scate.categories[index].categoryName,
                                )))),
                body: Stack(
                  children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: hasselect
                                ? (hascart ? 120.0 : 80.0)
                                : hascart
                                    ? 40
                                    : 0),
                        child: TabBarView(
                            children: List.generate(
                                scate.categories.length,
                                (index) => FoodMenu(
                                      categoriesFoodModel:
                                          scate.categories[index],
                                    )))),
                    hascart
                        ? BottomCart(
                            bottom: hasselect ? 80 : 0,
                            totalHarga: state.totalHarga)
                        : SizedBox.shrink(),
                    hasselect
                        ? SelectItemCart(item: state.onselect, hascart: hascart)
                        : SizedBox.shrink()
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class FoodMenu extends StatefulWidget {
  final CategoriesFoodModel categoriesFoodModel;

  const FoodMenu({Key key, this.categoriesFoodModel}) : super(key: key);

  @override
  _FoodMenuState createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu>
    with AutomaticKeepAliveClientMixin<FoodMenu> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (_) => FoodsCubit(
          connectivityCubit: BlocProvider.of<ConnectivityCubit>(context),
          categoriesFoodModel: widget.categoriesFoodModel)
        ..initial(),
      child: BlocBuilder<FoodsCubit, FoodsState>(
        builder: (_, state) {
          if (state.isinitial) {
            return Container(
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          return GridView.count(
            physics: BouncingScrollPhysics(),
            primary: false,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: List.generate(state.foods.length, (index) {
              FoodModel food = state.foods[index];
              return InkWell(
                onTap: () {
                  BlocProvider.of<CartCubit>(context).itemSelect(food);
                },
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: food.pcMobileThumb == null
                              ? Container()
                              : Image.network(
                                  '${Api.assetsUrl}${food.pcMobileThumb}',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${food.name}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Rp.${food.salePrice}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
