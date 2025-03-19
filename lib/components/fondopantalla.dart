import 'package:flutter/material.dart';

class FondoPantalla extends StatelessWidget {
  const FondoPantalla({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:const Color(0xff30BAD6),
      height: double.infinity,
      alignment: Alignment.topCenter,
      child: Container(color: Colors.white,),
      
    );
  }
}