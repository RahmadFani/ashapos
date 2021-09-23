import 'package:flutter/material.dart';

class BottomCart extends StatefulWidget {
  final double bottom;
  final int totalHarga;

  const BottomCart({Key key, this.bottom, this.totalHarga}) : super(key: key);

  @override
  _BottomCartState createState() => _BottomCartState();
}

class _BottomCartState extends State<BottomCart> {

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottom,
      left: 0,
      right: 0,
      height: 40,
      child: PhysicalModel(
          color: Colors.black,
          elevation: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total : ', style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15
              ),),
               Text('Rp. ${widget.totalHarga}', style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15
              ),)
            ],
          ),
        ),
      ));
  }
}