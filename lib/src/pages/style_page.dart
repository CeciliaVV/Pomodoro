import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget styleButton(double buttonwidth, double buttonHeight, double radius,
    double spreadRad, double offsetX, double offsetY, double blurRad) {
  return Container(
    width: buttonwidth,
    height: buttonHeight,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        color: Colors.teal[700],
        boxShadow: [
          BoxShadow(
            spreadRadius: spreadRad,
            color: Colors.white,
            offset: Offset(offsetX, offsetY),
            blurRadius: blurRad,
          )
        ]),
  );
}

Widget styleTextButton(
    String text, double buttonWidth, double buttonHeight, double radius) {
  return Container(
    width: buttonWidth,
    height: buttonHeight,
    decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(radius))),
    child: Container(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.sourceSerifPro(
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
          ),
        )),
  );
}

Widget styleTextSimple(String texto, double tamanio) {
  return Text(
    texto,
    textAlign: TextAlign.center,
    style: GoogleFonts.sourceSerifPro(
        textStyle: TextStyle(color: Colors.black, fontSize: tamanio)),
  );
}
