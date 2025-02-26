import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'Gewerbe.dart';        //auf firebase anpassen

/*class GewerbeLayoutNeu extends StatefulWidget{
  @override
  State<GewerbeLayoutNeu> createState() => _GewerbeLayoutNeuState();
}

class _GewerbeLayoutNeuState extends State<GewerbeLayoutNeu> {
  @override
 Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(width: 25),
                  const SizedBox(
                    height: 75,
                    width: 75,
                    child: Image(
                      image: AssetImage('Assets/wappen_Eichwalde.png'),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Gewerbe',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              SizedBox(
                height: 550,
                width: 380,
                child: ListView.builder(
                  itemCount: gewerbes.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 380,
                      //height: tileheight,       -> abhängig auch von Namenslänge
                      height: 400,        
                      child: Card(
                        child: ListTile(
                          title: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 300,
                                child: Image(
                                  image: AssetImage(gewerbes[index].image)
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                ),
                                textAlign: TextAlign.left,
                                gewerbes[index].name
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  } 
}*/

  