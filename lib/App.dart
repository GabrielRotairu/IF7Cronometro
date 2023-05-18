import 'package:cronometro/Cronometro/CronometroIF7.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      //Establecemos la ruta inicial
      initialRoute: '/Home',
      //Establecemos rutas de la app
      routes: {
        '/Home': (context) => Cronometro(),



      },
    );
  }
}