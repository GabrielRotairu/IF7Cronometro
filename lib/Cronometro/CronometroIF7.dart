import 'package:flutter/material.dart';
import 'dart:async';

import 'package:vibration/vibration.dart';

class Cronometro extends StatefulWidget {
  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  int segundosPasados = 0;
  bool estaCorriendo = false;
  int repeticiones = 1;
  int repeticionesRestantes = 1;
  int minutoParada = 1;
  int repeticionActual = 1;
  Timer? cronometro;

  void iniciarCronometro() {
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundosPasados++;
        if (segundosPasados >= 60) {
          segundosPasados = 0;
          if (segundosPasados % 60 == 0 && segundosPasados ~/ 60 == minutoParada) {
            detenerCronometro();
            mostrarDialogoFinalizado();
            Vibration.vibrate(duration: 2000);
          }
        }
      });
    });
  }

  void iniciarSiguienteRepeticion() {
    if (repeticionesRestantes > 0) {
      setState(() {
        repeticionesRestantes--;
        repeticionActual = repeticiones - repeticionesRestantes;
        segundosPasados = 0;
      });
      iniciarCronometro();
    }
  }

  void detenerCronometro() {
    cronometro?.cancel();
  }

  void reiniciarCronometro() {
    setState(() {
      segundosPasados = 0;
      repeticionesRestantes = repeticiones;
      repeticionActual = 1;
      estaCorriendo = false;
    });
    detenerCronometro();
  }

  String obtenerTiempoFormateado() {
    int segundos = segundosPasados % 60;
    int minutos = segundosPasados ~/ 60;
    int horas = segundosPasados ~/ 3600;

    String segundosStr = segundos.toString().padLeft(2, '0');
    String minutosStr = minutos.toString().padLeft(2, '0');
    String horasStr = horas.toString().padLeft(2, '0');

    return "$horasStr:$minutosStr:$segundosStr";
  }

  void mostrarDialogoFinalizado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Finalizado'),
          content: Text('Se han completado todas las repeticiones.'),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Aceptar'),
              onPressed: () {
                reiniciarCronometro();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Cronómetro'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              obtenerTiempoFormateado(),
              style: TextStyle(fontSize: 40),
            ),
            Text("Vueltas Restantes: "+repeticionesRestantes.toString()),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Repeticiones:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: repeticiones,
                  onChanged: (value) {
                    setState(() {
                      repeticiones = value!;
                      repeticionesRestantes = value!;
                    });
                  },
                  items: List.generate(10, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Minuto de parada:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                DropdownButton<int>(
                  value: minutoParada,
                  onChanged: (value) {
                    setState(() {
                      minutoParada = value!;
                    });
                  },
                  items: List.generate(7, (index) {
                    return DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(estaCorriendo ? Icons.pause : Icons.play_arrow),
                  color: Colors.green,

                  onPressed: () {
                    setState(() {
                      estaCorriendo = !estaCorriendo;
                    });
                    if (estaCorriendo) {
                      if (repeticionesRestantes > 0) {
                        iniciarCronometro();
                      }
                    } else {
                      detenerCronometro();
                    }
                  },
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.stop),
                  color: Colors.red,
                  onPressed: () {
                    reiniciarCronometro();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

