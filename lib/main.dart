import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pomodoro/src/pages/style_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomodoro',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer;

  bool activo = false;
  //variables temporales que se capturan en el showDialog y se muestran en los botones
  int minutosPom = 25; //minutos del tiempo de pomodoro
  int segundosPom = 0; //segundos del tiempo de pomodoro
  int minutosDes = 5; //minutos del tiempo de descanso
  int segundosDes = 0; //segundos del tiempo de descanso

  int min_25 = 1500; //duración del tiempo de pomodoro
  int min_5 = 300; //duración del tiempo de descanso
  int _start = 1500; //tiempo inicial que va a estar disminuyendo cada segundo

  int initialTime = 1500; //tiempo inicial

  //BOTONES -> 1:botón presionado, 0:botón sin presionar
  int paused = 1; //botón "Pausa"
  int reset_5 = 0; //botón "Comenzar"
  int reset_25 = 0; //botón del tiempo de pomodoro
  int reset = 0; //botón del tiempp de descanso

  //variables temporales
  int valor;
  int temporalMin;
  int temporalSeg;

  //variable que permitirá que el tiempo de descanso inicie inmediatamente
  //después del tiempo de pomodoro
  //0 mientras transcurra el tiempo de pomodoro y 1 mientras transcurra el tiempo de descanso
  int bandera = 0;

  //variables que se mostrarán como string en el circular percent progress
  String minutesStr;
  String secondsStr;

  //variables para el bucle del pomodoro
  int bucle = 1;
  int contadorBucle = 0;

  //variables para la verificación de los textFormField
  final formKey = new GlobalKey<FormState>();
  final formKey2 = new GlobalKey<FormState>();

  //variable para el sonido de la notificación
  final audioPlayer = AudioCache();

  //función que convierte los segundos al formato MM:SS
  String formato(int seconds) {
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    minutesStr = (minutes).toString().padLeft(2, '0');
    secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (seconds < 1 && bandera == 1) return "Pomodoro completado";

    return "$minutesStr:$secondsStr";
  }

  void notificacion() async {
    if (_start == 3 && bandera == 0)
      audioPlayer.play("11.mp3");
    else if (_start == 3 && bandera == 1) {
      audioPlayer.play("11.mp3");
      await Future.delayed(const Duration(seconds: 2));
      audioPlayer.play("11.mp3");
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (timer) {
      notificacion();
      setState(() {
        //si se acaba el tiempo de pomodoro, inicia el tiempo de descanso
        if (_start < 1 && bandera == 0) {
          _start = min_5;
          reset_5 = 0;
          initialTime = min_5;
          bandera++;
        } else {
          //si se acaba el tiempo de descanso, el tiempo inicial vuelve al tiempo de pomodoro y se pausa
          if (_start < 1 && bandera == 1) {
            _start = min_25;
            initialTime = min_25;
            bandera = 0;
            activo = false;
            contadorBucle++;
            if (bucle <= contadorBucle) {
              paused = 1;
            }
          }
          //mientras no esté pausado los segundos van a transcurrir
          if (paused == 0) {
            _start = _start - 1;
          }
          //si se presiona el botón de tiempo de pomodoro, se inicializa el tiempo con el tiempo de pomodoro
          if (reset_25 == 1) {
            _start = min_25;
            reset_25 = 0;
            initialTime = min_25;
          }
          //si se presiona el botón de tiempo de descanso, se inicializa el tiempo con el tiempo de descanso
          if (reset_5 == 1) {
            _start = min_5;
            reset_5 = 0;
            initialTime = min_5;
          }
          //si se presiona el botón de comenzar, se inicializa el tiempo con el tiempo de pomodoro
          if (reset == 1) {
            _start = min_25;
            initialTime = min_25;
            reset = 0;
            paused = 0;
            activo = true;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
            child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.greenAccent, Colors.teal],
                        begin: FractionalOffset(0.25, 1))),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(crossAxisAlignment: CrossAxisAlignment.center,
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(width: 130),
                            styleTextSimple(
                                bandera == 0 ? "Pomodoro" : "Descanso", 50),
                            SizedBox(width: 70),
                            configuraciones()
                          ]),
                      SizedBox(height: 10),
                      new CircularPercentIndicator(
                        radius: 330.0,
                        lineWidth: 20.0,
                        reverse: true,
                        percent: _start / initialTime,
                        center: styleTextSimple(formato(_start), 50),
                        backgroundColor: Colors.black,
                        progressColor: Colors.greenAccent,
                      ),
                      Spacer(),
                      SizedBox(height: 5),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            !activo
                                ? Expanded(
                                    flex: 10,
                                    child:
                                        button("Comenzar", reset, 140, 60, 25),
                                  )
                                : paused == 0
                                    ? Expanded(
                                        flex: 10,
                                        child: button(
                                            "Pausa", paused, 140, 60, 25),
                                      )
                                    : Expanded(
                                        flex: 10,
                                        child: button(
                                            "Continuar", paused, 140, 60, 25),
                                      ),
                            activo
                                ? Expanded(
                                    flex: 10,
                                    child:
                                        button("Detener", reset, 140, 60, 25),
                                  )
                                : Container(),
                          ]),
                      SizedBox(height: 30),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            styleTextSimple("Tiempo de pomodoro:", 20),
                            styleTextSimple("Tiempo de descanso:", 20),
                          ]),
                      SizedBox(height: 15),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: button("$minutosPom Min $segundosPom Seg",
                                  reset_25, 140, 60, 25),
                            ),
                            Expanded(
                              flex: 10,
                              child: button("$minutosDes Min $segundosDes Seg",
                                  reset_5, 140, 60, 25),
                            )
                          ]),
                      Spacer(),
                    ],
                  ),
                ))),
      ),
    );
  }

  Widget button(String text, int status, double buttonWidth,
      double buttonHeight, double radius) {
    if (status == 0) //si el botón no está presionando
      return unpressedButton(text, buttonWidth, buttonHeight, radius);
    else
      return pressedButton(text, buttonWidth, buttonHeight, radius);
  }

  //caja del botón cuando está no presionado (el brillo blanco aparece abajo)
  Widget unpressedButton(
      String text, double buttonWidth, double buttonHeight, double radius) {
    return Stack(
      alignment: Alignment.center,
      children: [
        styleButton(
            buttonWidth, buttonHeight, radius, -2, 3, 3, 7), //caja del botón
        styleButton(buttonWidth, buttonHeight, radius, -2, 3, 3,
            7), //para más brillo en la caja del botón
        MaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: styleTextButton(text, buttonWidth, buttonHeight, radius),
          onPressed: () {
            setState(() {
              //si está presionado y aprieto el botón deja de estar en estado presionado y viceversa
              if (text == "Pausa" || text == "Continuar") {
                if (paused == 1)
                  paused = 0;
                else
                  paused = 1;
              }
              if (text == "$minutosPom Min $segundosPom Seg") {
                //Función que retorna un showDialog para ingresar los minutos y segundos.
                //El segundo parámetro indica si se ingresa el tiempo de descanso o no.
                ingresaTiempo(context, false);
                reset_25 = 1;
              } else if (text == "$minutosDes Min $segundosDes Seg") {
                ingresaTiempo(context, true);
                reset_5 = 1;
              }
              if (text == "Comenzar") {
                _start = min_25;
                initialTime = min_25;
                reset = 1;
                contadorBucle = 0;
              }
              if (text == "Detener") {
                activo = false;
                _start = min_25;
                initialTime = min_25;
                contadorBucle = 0;
                paused = 1;
              }
            });
          },
        )
      ],
    );
  }

  //caja del botón cuando está presionado (el brillo blanco aparece arriba)
  Widget pressedButton(
      String text, double buttonWidth, double buttonHeight, double radius) {
    return Stack(
      alignment: Alignment.center,
      children: [
        styleButton(buttonWidth, buttonHeight, radius, -12, 2, 2, 7),
        styleButton(buttonWidth, buttonHeight, radius, -2, -4, -4, 7),
        MaterialButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: styleTextButton(text, buttonWidth, buttonHeight, radius),
          onPressed: () {
            setState(() {
              //Solo se cambia el estado del botón pausa porque es el único que puede estar presionado por
              //un largo tiempo, los demás botones cambian de estado inmediatamente después de ser presionados.
              if (text == "Pausa" || text == "Continuar") {
                if (paused == 1)
                  paused = 0;
                else
                  paused = 1;
              }
            });
          },
        )
      ],
    );
  }

  //función donde se puede ingresar los minutos y segundos del tiempo de pomodoro
  //y descanso, también se validan los datos
  ingresaTiempo(BuildContext context, bool descanso) {
    paused = 1;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                descanso ? 'Tiempo de descanso' : 'Tiempo de pomodoro',
                style: GoogleFonts.sourceSerifPro(),
              ),
              content: SizedBox(
                  width: 100.0,
                  height: 210.0,
                  child: Center(
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (valor) {
                                      if (valor.isEmpty)
                                        return 'Debe ingresar datos.';
                                      if (int.parse(valor) > 59 ||
                                          int.parse(valor) < 0)
                                        return 'Número no válido.';
                                      return null;
                                    },
                                    onSaved: (valor) =>
                                        temporalMin = int.parse(valor),
                                    decoration: InputDecoration(
                                        labelText: 'Minutos',
                                        prefixIcon: descanso
                                            ? Icon(Icons.pan_tool)
                                            : Icon(Icons.alarm)),
                                    style: GoogleFonts.sourceSerifPro()),
                                SizedBox(height: 15.0),
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (valor) {
                                      if (valor.isEmpty)
                                        return 'Debe ingresar datos.';
                                      if (int.parse(valor) > 59 ||
                                          int.parse(valor) < 0)
                                        return 'Número no válido.';
                                      return null;
                                    },
                                    onSaved: (valor) =>
                                        temporalSeg = int.parse(valor),
                                    decoration: InputDecoration(
                                        labelText: 'Segundos',
                                        prefixIcon: descanso
                                            ? Icon(Icons.pan_tool)
                                            : Icon(Icons.alarm)),
                                    style: GoogleFonts.sourceSerifPro()),
                                SizedBox(height: 20.0),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text("Cancelar",
                                            style: GoogleFonts.sourceSerifPro(
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      SizedBox(width: 20.0),
                                      TextButton(
                                        child: Text("Aceptar",
                                            style: GoogleFonts.sourceSerifPro(
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        onPressed: () {
                                          if (formKey.currentState.validate()) {
                                            formKey.currentState.save();
                                            //si el formulario es correcto configuro los tiempos dependiendo si está en descanso o no
                                            setState(() {
                                              if (!descanso) {
                                                minutosPom = temporalMin;
                                                segundosPom = temporalSeg;
                                                _start = minutosPom * 60 +
                                                    segundosPom;
                                                min_25 = minutosPom * 60 +
                                                    segundosPom;
                                                initialTime = _start;
                                              } else if (descanso) {
                                                minutosDes = temporalMin;
                                                segundosDes = temporalSeg;
                                                min_5 = minutosDes * 60 +
                                                    segundosDes;
                                                _start = minutosPom * 60 +
                                                    segundosPom;
                                                initialTime = _start;
                                              }
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ])
                              ],
                            ),
                          )))),
            ));
  }

  Widget configuraciones() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(
        width: 35,
        height: 35,
        child: FloatingActionButton(
          mini: true,
          child: Icon(
            Icons.settings,
            size: 23,
          ),
          backgroundColor: Colors.teal[700],
          onPressed: () {
            configurarBucle();
          },
        ),
      ),
      /*SizedBox(
        width: 20,
      ),
      styleTextSimple("$contadorBucle",
          25)*/ //contador de repeticiones que empieza en 0 y va en aumento
    ]);
  }

  void configurarBucle() {
    int temporal;
    paused = 1;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Configurar repeticiones',
                style: GoogleFonts.sourceSerifPro(),
              ),
              content: SizedBox(
                  width: 80.0,
                  height: 120.0,
                  child: Center(
                      child: Form(
                          key: formKey2,
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                    keyboardType: TextInputType.number,
                                    validator: (valor) {
                                      if (valor.isEmpty)
                                        return 'Debe ingresar datos.';
                                      if (int.parse(valor) <= 0)
                                        return 'Número no válido.';
                                      return null;
                                    },
                                    onSaved: (valor) =>
                                        temporal = int.parse(valor),
                                    decoration: InputDecoration(
                                        labelText: 'Repeticiones',
                                        prefixIcon: Icon(Icons.loop_outlined)),
                                    style: GoogleFonts.sourceSerifPro()),
                                SizedBox(height: 20.0),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text("Cancelar",
                                            style: GoogleFonts.sourceSerifPro(
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      SizedBox(width: 20.0),
                                      TextButton(
                                        child: Text("Aceptar",
                                            style: GoogleFonts.sourceSerifPro(
                                                textStyle: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                        onPressed: () {
                                          if (formKey2.currentState
                                              .validate()) {
                                            formKey2.currentState.save();
                                            setState(() {
                                              bucle =
                                                  temporal; //bucle por defecto comienza con 1 repetición, pero se puede configurar
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ])
                              ],
                            ),
                          )))),
            ));
  }
}
