import 'package:flutter/material.dart';

//App-Files
//import 'package:eichwalde_app/Design/eichwalde_design.dart';

class OrtPage extends StatefulWidget {
  const OrtPage({super.key});

  @override
  State<OrtPage> createState() => _OrtPageState();
}

class _OrtPageState extends State<OrtPage> { 
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: MediaQuery.of(context).size.height*0.745,  //ist eig kaka
          width: constraints.maxWidth*0.95,
          child: ListView(
            children: [
            ],
          ),
        );
      }
    );
  }
}