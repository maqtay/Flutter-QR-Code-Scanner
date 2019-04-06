import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';



void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
  )
);

class HomePage extends StatefulWidget{
  HomePageState createState(){
    return new HomePageState();
  }
}
class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin{
  String result, supportLink = "http://maqtay.com";
  List<String> list = [];
  bool status = false;

  Future _scanqr () async {
    try {
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        _neverSatisfied();
      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = 'Camera permission was denied';
        });
      } else {
        setState(() {
          result = 'Unkown error $ex';
        });
      }
    } on FormatException {
      Fluttertoast.showToast(
        msg:"Has been canceled!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        fontSize: 16.0,
        backgroundColor: Colors.red,
      );
      setState(() {
        result = null;
      });
    } catch (ex) {
      setState(() {
        result = 'Unkown error $ex';
      });
    }
  }
  _launchUrl() async{
    if(await canLaunch(result)){
      await launch(result);
    }else{
      throw 'Could not launch $result';
    }
  }
  _support() async{
    if(await canLaunch(supportLink)){
      await launch(supportLink);
    }else{
      throw "Could not launch $supportLink";
    }
  }
  Future<void> _neverSatisfied() async {
    return showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Sonuç'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(result),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed:() {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Re-Scan'),
                onPressed: _scanqr,
              ),

              FlatButton(
                child: Text('Go'),
                onPressed: _launchUrl,
              ),
            ],
          );
        }
    );
  }

  void _showDialog() {
    showDialog(
        context: context,
      builder: (BuildContext context){
          return AlertDialog(
            title: Text("About",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: new Text("MaqtayApp"),
            actions: <Widget>[
              FlatButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                  label: Text("Close"),
              ),
              FlatButton.icon(
                  onPressed: () => _support(),
                  icon: Icon(Icons.check),
                  label: Text("Support")
              )
            ],
          );
      }
    );
  }
  Widget build (BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Scan Qr Code"),
          centerTitle: true,
          backgroundColor: Colors.blue
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0.1, 0.5, 0.7, 0.9],
                colors:[
                    // Colors are easy thanks to Flutter's Colors class.
                    Colors.purple[800],
                    Colors.purple[700],
                    Colors.purple[600],
                    Colors.purple[400],
                  ],
              )
            ),
            padding: EdgeInsets.fromLTRB(80.0, 140.0, 80.0, 140.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton.extended(
                    icon: Icon(Icons.camera_alt),
                    label: Text("Scan"),
                    onPressed: _scanqr,
                    backgroundColor: Colors.amber,
                  ),
                  FloatingActionButton.extended(
                      icon: Icon(Icons.person_pin),
                      label: Text("About"),
                      onPressed: _showDialog,
                      backgroundColor: Colors.amber,
                  ),
                  FloatingActionButton.extended(
                    onPressed: () => exit(0),
                    icon: Icon(Icons.close),
                    label: Text("Exit"),
                    backgroundColor: Colors.amber,
                  ),
                ]
            ),
          ),
        ),
    );
  }
}