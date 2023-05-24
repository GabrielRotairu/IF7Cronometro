import 'package:flutter/material.dart';
import 'dart:async';

import 'package:vibration/vibration.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

class Cronometro extends StatefulWidget {
  @override
  _CronometroState createState() => _CronometroState();
}

class _CronometroState extends State<Cronometro> {
  int segundosPasados = 0;
  bool estaCorriendo = false;
  int repeticiones = 1;
  int repeticionesRestantes = 0;
  int minutoParada = 1;
  int repeticionActual = 1;
  Timer? cronometro;
  FlutterIsolate? backgroundIsolate;

  @override
  void initState() {
    super.initState();
    startBackgroundIsolate();
  }

  @override
  void dispose() {
    super.dispose();
    stopBackgroundIsolate();
  }

  void startBackgroundIsolate() async {
    backgroundIsolate = await FlutterIsolate.spawn(runBackgroundTimer, null);
  }

  void stopBackgroundIsolate() {
    if (backgroundIsolate != null) {
      backgroundIsolate!.kill();
      backgroundIsolate = null;
    }
  }

  static void runBackgroundTimer(dynamic _) {
    int segundosPasados = 0;
    int repeticionesRestantes = 1; // Actualiza este valor con el número de vueltas restantes

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      segundosPasados++;
      if (segundosPasados >= 60) {
        segundosPasados = 0;
        repeticionesRestantes--;
        if (repeticionesRestantes <= 0) {
          timer.cancel();

        }
      }
    });
  }

  void iniciarCronometro() {
    cronometro = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        segundosPasados++;
        if (segundosPasados >= 60) {
          segundosPasados = 0;
          if (segundosPasados % 60 == 0 &&
              segundosPasados ~/ 60 == minutoParada) {
            detenerCronometro();
            mostrarDialogoFinalizado();

          }
          Vibration.vibrate();
          iniciarSiguienteRepeticion();
        }
      });
    });
  }

  void iniciarSiguienteRepeticion() {
    repeticiones=repeticionesRestantes;
    if (repeticionesRestantes > 0) {
      setState(() {
        repeticionesRestantes--;
        repeticionActual = repeticiones - repeticionesRestantes;
        segundosPasados = 0;
      });
    }
    detenerCronometro();
  }

  void detenerCronometro() {
    cronometro?.cancel();
  }

  void reiniciarCronometro() {
    setState(() {
      segundosPasados = 0;
      repeticionesRestantes = repeticiones;
      repeticionActual = 0;
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
            Text("Vueltas Restantes: " + repeticionesRestantes.toString()),
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
