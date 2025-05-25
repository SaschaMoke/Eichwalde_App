import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget{
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Über die Eichwalde App'),
        actions: [
          /*IconButton(
            onPressed: () {
              
            },
            icon: const Icon(Icons.favorite_outline_rounded),
          )*/
          //Feedback oder so?
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              height: MediaQuery.of(context).size.height*0.95,
              width: constraints.maxWidth*0.95,
              child: ListView(
                children: [
                  Image(
                    height: constraints.maxWidth*0.2,
                    image: const AssetImage('Assets/IconEichwaldeneu2.png')
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: constraints.maxWidth*0.075
                    ),
                    'App'
                  ), 
                  const SizedBox(height: 10),
                  Text(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: constraints.maxWidth*0.05
                    ),
                    'Lorem Impsum projekt'
                  ), 
                ],
              )
            );
          },
        ),
      ),
    );
  }
}