
// import 'package:ashapos/blocs/cart/cart_cubit.dart';
// import 'package:ashapos/models/item_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class DrinkTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//      List<ItemModel> foods = mylistitems.where((element) => element.isdrink).toList();

//     return GridView.count(
//       physics: BouncingScrollPhysics(),
//       primary: false,
//       padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
//       crossAxisSpacing: 10,
//       childAspectRatio: 1.5,
//       mainAxisSpacing: 10,
//       crossAxisCount: 2,
//       children: List.generate(foods.length, (index) {
//         return InkWell(
//           onTap: () {
//             BlocProvider.of<CartCubit>(context).itemSelect(foods[index]);
//           },
//   child: Card(
//                     elevation: 5,
//                                       child: Container(
//             padding: const EdgeInsets.all(8),
//             child: Text("${foods[index].nama}"),
//           ),
//                   ),
//         );
//       }),
//     );
  
//   }
// }