import 'package:ashapos/blocs/cart/cart_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectItemCart extends StatefulWidget {
  final CartItems item;
  final bool hascart;

  const SelectItemCart({Key key, this.item, this.hascart}) : super(key: key);

  @override
  _SelectItemCartState createState() => _SelectItemCartState();
}

class _SelectItemCartState extends State<SelectItemCart> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: 80,
        child: PhysicalModel(
          color: Colors.black,
          elevation: widget.hascart ? 0 : 20,
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.itemModel.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        Text(
                          'Rp.' + widget.item.itemModel.salePrice.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  if (widget.item.qty > 0)
                    Material(
                        child: IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              BlocProvider.of<CartCubit>(context)
                                  .removeQtyItem(widget.item.itemModel);
                            })),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.item.qty.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Material(
                      child: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            BlocProvider.of<CartCubit>(context)
                                .addToCart(widget.item.itemModel);
                          })),
                ],
              ),
            ),
          ),
        ));
  }
}
