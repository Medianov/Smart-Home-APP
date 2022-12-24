import 'dart:async';
import 'dart:io';
import 'package:asbool/asbool.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:smart_home/authentication_screens/auth.dart';


class Modus extends StatefulWidget {
  const Modus({Key? key}) : super(key: key);

  @override
  State<Modus> createState() => _ModusState();
}

class _ModusState extends State<Modus> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  TextEditingController name = TextEditingController();
  String userID = "";
  int AnzahlLights = 0;
  int AnzahlCurtains = 0;
  int AnzahlModus = 0;
  List<Widget> geraetelist = [];
  List<Widget> geraetelist2 = [];
  List<Widget> moduswidget = [];
  bool connected = false;

  //int add=1;

  TimeOfDay rechtstime = TimeOfDay.now();
  TimeOfDay linkstime = TimeOfDay.now();
  Timer? _timer;

  @override
  initState() {
    super.initState();
    getData();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
  }

  internet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connected=true;
      }
    } on SocketException catch (_) {
      connected=false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple[400],
          actions: [
            IconButton(onPressed: () {
              name_eingeben(context);
            }, icon: Icon(Icons.add))
          ],
          title: Text(
            'Modus',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder(
            initialData: getData() ,
            builder:(context, AsyncSnapshot snapshot) {
              internet();
              if (connected) {
                return DelayedDisplay(
                  delay: Duration(milliseconds: 150),
                  child:
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.94,
                    ),
                    itemCount: moduswidget.length,
                    itemBuilder: (context,index){
                      return
                        moduswidget[index];
                    }, ),


                );
              } else {
                return Center(child: CircularProgressIndicator(
                  color: Colors.grey,
                  backgroundColor: Colors.white,
                ));}}),
    );
  }

  Widget testcard(String i,
      String name,
      bool motoron,
      bool motortimer,
      bool rechts,
      bool links,
      int rechtsstunde,
      int rechtsminute,
      int linksstunde,
      int linksminute,
      ValueNotifier<Color> colors,
      bool lights,
      bool curtains,
      bool kombi) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            update_geraete_liste(i);
            popwidget(
                context,
                i,
                name,
                motoron,
                motortimer,
                rechts,
                links,
                rechtsstunde,
                rechtsminute,
                linksstunde,
                linksminute,
                colors,
                lights,
                curtains,
                kombi);
          });
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 2.0,
                color: Colors.cyan.shade800,
              ),
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(5, 12, 0, 0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.palette,
                      color: Colors.deepPurple[100],
                      size: 30,
                    ),
                  ],),
                SizedBox(
                  height: 20,
                ),
                Text(name,textAlign: TextAlign.center,style: TextStyle(fontSize: 18,color: Colors.deepPurple[200]),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    switchbutton(motoron, i, "motoron",setState),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: (){
                      loeschen(context, name, i);
                    }, icon: Icon(Icons.delete,size: 20,color: Colors.deepPurple[100],)),
                  ],),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> popwidget(BuildContext context,
      String i,
      String name,
      bool motoron,
      bool motortimer,
      bool rechts,
      bool links,
      int rechtsstunde,
      int? rechtsminute,
      int? linksstunde,
      int? linksminute,
      ValueNotifier<Color> colors,
      bool lights,
      bool curtains,
      bool kombi) {
    return showDialog(
        context: context,
        builder: (context) {

          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Column(
                children: [
                  Text("Modus ID: $i"),
                  Text("Name: $name",textAlign: TextAlign.center,style: TextStyle(
                      fontSize: 20
                  ),),
                ],
              ),
              content: Container(
                width: double.minPositive,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextButton(onPressed: () async {
                        await internet();
                        _timer?.cancel();
                        await EasyLoading.show(
                          status: 'loading...',
                          maskType: EasyLoadingMaskType.black,
                        );
                        if(connected){
                          update_geraete_liste(i);
                          geraete(context, i);
                        }else{
                          EasyLoading.showError('kein Internet Verbindung');
                        }

                        EasyLoading.dismiss();
                      }, child: Text("Modus bearbeiten",style: TextStyle(color: Colors.amber[500]),),),
                      Visibility(
                        visible: curtains || lights,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Timer"),
                            switchbutton(motortimer, i, "motortimer",setState),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: curtains && lights,
                          child:  Row(
                            children: [
                              Checkbox(
                                //checkColor:
                                activeColor: Colors.cyan.shade800,
                                value: kombi,
                                onChanged: (value) async{
                                  await internet();
                                  _timer?.cancel();
                                  await EasyLoading.show(
                                    status: 'loading...',
                                    maskType: EasyLoadingMaskType.black,
                                  );
                                  if(connected){
                                  setState(() {
                                    kombi = value!;
                                    int val = (kombi) ? 1 : 0;
                                    databaseReference.child(userID).child("modus").child(i).child(
                                        "kombi").set(val);
                                    databaseReference.child(userID).child("modus").child(i).child(
                                        "rechtsstunde").set(0);
                                    databaseReference.child(userID).child("modus").child(i).child(
                                        "rechtsminute").set(0);
                                    databaseReference.child(userID).child("modus").child(i).child(
                                        "linksstunde").set(0);
                                    databaseReference.child(userID).child("modus").child(i).child(
                                        "linksminute").set(0);
                                    rechtsstunde=0;
                                    rechtsminute=0;
                                   linksstunde=0;
                                    linksminute=0;

                                  });
                                  }else{

                                    EasyLoading.showError('kein Internet Verbindung');
                                    }
                                  EasyLoading.dismiss();
                                },),
                              Text("Kombination auswählen")
                            ],
                          )),

                      Visibility(
                        visible: (curtains && lights) && kombi,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "links", linkstime,"stop","start");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    linksminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksminute")
                                        .value)
                                        .toString());
                                    linksstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Links/Stop",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${linksstunde}:${linksminute}"),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (curtains && lights) && kombi,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "rechts", rechtstime,"stop","start");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    rechtsminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsminute")
                                        .value)
                                        .toString());
                                    rechtsstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Rechts/Start",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${rechtsstunde}:${rechtsminute}"),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: (curtains && lights) && !kombi,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "links", linkstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    linksminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksminute")
                                        .value)
                                        .toString());
                                    linksstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Links/Start",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${linksstunde}:${linksminute}"),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (curtains && lights) && !kombi,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "rechts", rechtstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    rechtsminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsminute")
                                        .value)
                                        .toString());
                                    rechtsstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Rechts/Stop",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${rechtsstunde}:${rechtsminute}"),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: curtains && !lights,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "links", linkstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    linksminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksminute")
                                        .value)
                                        .toString());
                                    linksstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Links",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${linksstunde}:${linksminute}"),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: curtains && !lights,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "rechts", rechtstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    rechtsminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsminute")
                                        .value)
                                        .toString());
                                    rechtsstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Rechts",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${rechtsstunde}:${rechtsminute}"),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: !curtains && lights,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "links", linkstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    linksminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksminute")
                                        .value)
                                        .toString());
                                    linksstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("linksstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Start",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${linksstunde}:${linksminute}"),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !curtains && lights,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await Zeit(context, i, "rechts", rechtstime,"start","stop");
                                  DataSnapshot snapshot = await databaseReference
                                      .child(userID).get();
                                  setState(() {
                                    rechtsminute = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsminute")
                                        .value)
                                        .toString());
                                    rechtsstunde = int.parse((snapshot
                                        .child("modus")
                                        .child(i)
                                        .child("rechtsstunde")
                                        .value)
                                        .toString());
                                    rechts = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("rechts").value).toString() )?? 0);
                                    links = asBool(int.tryParse((snapshot.child("modus").child(i.toString()).child("links").value).toString() )?? 0);
                                    motortimer =asBool(int.tryParse((snapshot.child("modus").child(i).child("motortimer").value).toString() )?? 0);
                                  });
                                },
                                child: Text("Stop",style: TextStyle(color: Colors.amber[500]),)),
                            Text("${rechtsstunde}:${rechtsminute}"),
                          ],
                        ),
                      ),

                      Visibility(
                        visible: curtains,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Links"),
                            switchbutton(rechts, i, "rechts",setState),
                            Text("Rechts"),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: lights,
                        child: Container(
                          child: ValueListenableBuilder<Color>(
                            valueListenable: colors,
                            builder: (_, colors, __) {
                              return Column(
                                children: [
                                  ColorPicker(
                                    color: colors,
                                    onChanged: (value) {
                                      colors = value;
                                    },
                                  ),
                                  ElevatedButton(style: ElevatedButton.styleFrom(
                                  primary: Colors.cyan[800], // Background color
                              ),onPressed: () {
                                    verify(ValueNotifier<Color>(colors), i);
                                  }, child: Text('Farbe ändern')),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),

              actions: <Widget>[
                Padding(
                  padding:  EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(

                        child: Text('Bearbeiten',style: TextStyle(color: Colors.amber[500]),),
                        onPressed: () async {
                          _timer?.cancel();
                          await EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.black,
                          );

                          setState(() {
                            Navigator.pop(context);
                            name_bearbeiten(context,i);
                          });

                          EasyLoading.dismiss();
                        },
                      ),
                      FlatButton(
                        color: Colors.deepPurple[400],
                        textColor: Colors.white,
                        child: Text('Fertig'),
                        onPressed: () async {
                          _timer?.cancel();
                          await EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.black,
                          );

                          setState(() {
                            Navigator.pop(context);
                          });

                          EasyLoading.dismiss();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }
  verify(ValueNotifier<Color> colors, String i) async {
    await internet();
    _timer?.cancel();
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );

    double red = colors.value.red.toDouble();
    double green = colors.value.green.toDouble();
    double blue = colors.value.blue.toDouble();
    double opacity = colors.value.opacity;
    int alpha = colors.value.alpha;
    int edit_red = (red * opacity).toInt();
    int edit_green = (green * opacity).toInt();
    int edit_blue = (blue * opacity).toInt();
    if(connected){
      databaseReference.child(userID).child("modus").child(i).child("red").set(
          edit_red);
      databaseReference.child(userID).child("modus").child(i).child("green").set(
          edit_green);
      databaseReference.child(userID).child("modus").child(i).child("blue").set(
          edit_blue);
      databaseReference.child(userID).child("modus").child(i)
          .child("helligkeit")
          .set(alpha);
      FirebaseDatabase.instance
          .ref(userID)
          .child("modus")
          .child(i)
          .child("ids")
          .onValue
          .listen((event) {
        event.snapshot.children.forEach((element) {
          String j = element.key.toString();
          element.children.forEach((element2) {
            String jj = element2.key.toString();
            if (jj == "lights") {
              databaseReference.child(userID).child("lights").child(j).child(
                  "red").set(edit_red);
              databaseReference.child(userID).child("lights").child(j).child(
                  "green").set(edit_green);
              databaseReference.child(userID).child("lights").child(j).child(
                  "blue").set(edit_blue);
              databaseReference.child(userID).child("lights").child(j).child(
                  "helligkeit").set(alpha);
            }
          });
        });
      });
    }else{
      EasyLoading.showError('kein Internet Verbindung');
    }

    EasyLoading.dismiss();
  }

  onchanged() {
    databaseReference
        .child(userID)
        .onValue
        .listen((event) {
      getData();
    });
  }

  getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    userID = user!.uid;
    DataSnapshot snapshot = await databaseReference.child(userID).get();


    await FirebaseFirestore.instance.collection("user").doc(user.uid)
        .get()
        .then((db) {
      return [
        db.data()!['AnzahlLights'] == null ? AnzahlLights = 0 : AnzahlLights =
        db.data()!['AnzahlLights'],
        db.data()!['AnzahlCurtains'] == null
            ? AnzahlCurtains = 0
            : AnzahlCurtains = db.data()!['AnzahlCurtains'],
        db.data()!['AnzahlModus'] == null ? AnzahlModus = 0 : AnzahlModus =
        db.data()!['AnzahlModus'],
      ];
    });


    FirebaseDatabase.instance
        .ref(userID)
        .child("modus")
        .onValue
        .listen((event) {
      if (moduswidget.isNotEmpty) {
        moduswidget.clear();
      }

      for (var element in event.snapshot.children) {
        if (!mounted) return;
        var i = element.key;
        moduswidget.add(testcard(
          i.toString(),
          (snapshot
              .child("modus")
              .child(i.toString())
              .child("modus_name")
              .value).toString(),
          asBool(int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("motoron")
              .value).toString()) ?? 0),
          asBool(int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("motortimer")
              .value).toString()) ?? 0),
          asBool(int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("rechts")
              .value).toString()) ?? 0),
          asBool(int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("links")
              .value).toString()) ?? 0),
          int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("rechtsstunde")
              .value).toString()) ?? 0,
          int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("rechtsminute")
              .value).toString()) ?? 0,
          int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("linksstunde")
              .value).toString()) ?? 0,
          int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("linksminute")
              .value).toString()) ?? 0,
          ValueNotifier<Color>(Color.fromARGB(
            int.tryParse((snapshot
                .child("modus")
                .child(i.toString())
                .child("helligkeit")
                .value).toString()) ?? 0,
            int.tryParse((snapshot
                .child("modus")
                .child(i.toString())
                .child("red")
                .value).toString()) ?? 0,
            int.tryParse((snapshot
                .child("modus")
                .child(i.toString())
                .child("green")
                .value).toString()) ?? 0,
            int.tryParse((snapshot
                .child("modus")
                .child(i.toString())
                .child("blue")
                .value).toString()) ?? 0,
          ),
          ),
          snapshot
              .child("modus")
              .child(i.toString())
              .child("lights")
              .exists,
          snapshot
              .child("modus")
              .child(i.toString())
              .child("curtains")
              .exists,
          asBool(int.tryParse((snapshot
              .child("modus")
              .child(i.toString())
              .child("kombi")
              .value).toString()) ?? 0),
        ));
      }
    });
    if (!mounted) return;
    setState(() {

    });
  }

  void _addCardWidget() {
    setState(() {
      AnzahlModus++;
      databaseReference.child(userID).child("modus").child(
          AnzahlModus.toString()).update({
        "modus_name": name.text,
        "helligkeit": 0,
        "red": 0,
        "green": 0,
        "blue": 0,
        "linksstunde": 0,
        "linksminute": 0,
        "rechtsstunde": 0,
        "rechtsminute": 0,
        "links": 0,
        "rechts": 0,
        "motoron": 0,
        "motortimer": 0,
        "kombi":0,
        "curtains_name": "",
        "lights_name": "",

      });
      Update(context);
      Timer(Duration(microseconds: 50), () {
        getData();
      });
    });
  }

  Update(BuildContext context) {
    DatabaseManager().updateUserList(
        AnzahlLights,
        AnzahlCurtains,
        AnzahlModus,
        userID

    );
  }

  Future<void> name_eingeben(BuildContext context) async {
    final _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
              title: Text('Bitte geben Sie einen Name:'),
              content: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Dieses Field kann nicht leer sein.';
                  }
                  return null;
                },
                controller: name,
                decoration: InputDecoration(hintText: "hier eingeben"),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Abbrechen'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                      FlatButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('fertig'),
                        onPressed: () async {
                          await internet();
                          _timer?.cancel();
                          await EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.black,
                          );

                          setState(() {
                            final String namee = name.text.trim();
                            if(connected){
                              if (namee.isNotEmpty) {
                                _addCardWidget();
                                Navigator.pop(context);
                              }
                            }else{
                              EasyLoading.showError('kein Internet Verbindung');
                            }


                            if (_key.currentState!.validate()) {}
                          });
                          EasyLoading.dismiss();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> name_bearbeiten(BuildContext context,String i) {
    final _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
              title: Text('Bitte geben Sie einen Name:'),
              content: TextFormField(
                maxLength: 20,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Dieses Field kann nicht leer sein.';
                  }
                  return null;
                },
                controller: name,
                decoration: InputDecoration(hintText: "hier eingeben"),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Abbrechen'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                      FlatButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('OK'),
                        onPressed: () async {
                          await internet();
                          _timer?.cancel();
                          await EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.black,
                          );

                          setState(() {
                            final String namee = name.text.trim();
                            if(connected){
                              if (namee.isNotEmpty) {
                                databaseReference.child(userID).child("modus").child(i.toString()).update({
                                  "modus_name": namee,
                                });
                                Navigator.pop(context);

                              }
                            }else{
                              EasyLoading.showError('kein Internet Verbindung');
                            }


                            if (_key.currentState!.validate()) {}
                          });
                          EasyLoading.dismiss();
                        },
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );
        });
  }

  Future<void> geraete(BuildContext context, String i) async {

    return showDialog(

        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('verfuegbare Gerate:',
              //style: TextStyle(color: Colors.deepPurple[400]),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.deepPurple[400],
                textColor: Colors.white,
                onPressed: () async {
                  _timer?.cancel();
                  await EasyLoading.show(
                    status: 'loading...',
                    maskType: EasyLoadingMaskType.black,
                  );

                  Navigator.pop(context);
                  Navigator.pop(context);
                  EasyLoading.dismiss();
                },
                child: Text('fertig'),
              ),
            ],
            content:Container(
              width: double.minPositive,
              child: Column(
            
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                              color: Colors.cyan.shade800,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(50, 8, 50, 8),
                        child: Text("Curtains" ,style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.deepPurple[100],
                        ),),
                      )),

                  SizedBox(height: 10,),
                    Expanded(
                      child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: geraetelist.length,
                            itemBuilder: (BuildContext context, int index) {
                              return geraetelist[index];
                            },
                          ),
                    ),
                  SizedBox(height: 10,),
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            width: 2.0,
                            color: Colors.cyan.shade800,
                          ),
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(60, 8, 60, 8),
                        child: Text("Lights" ,style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.deepPurple[100],
                        ),),
                      )),
                  SizedBox(height: 10,),
                  Expanded(
                    child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: geraetelist2.length,
                          itemBuilder: (BuildContext context, int index) {
                            return geraetelist2[index];
                          },
                        ),
                  )

                ],
              ),
            ),
          );
        });
  }

  Widget curtains_namen(String name, int id, String i, bool check) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 5, 0.0, 5),
      child:
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /*Text("${id.toString()} "),*/
          Icon(Icons.curtains, color: Colors.deepPurple[100],),
          SizedBox(width: 15,),
          Expanded(child: Text(
            "$name",
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Colors.deepPurple[100],
            ),
          ),),


          switchhh(check, id, i)
        ],
      ),


    );
  }

  Widget lights_namen(String name, int id, String i, bool check) {
    return
      Padding(
        padding: EdgeInsets.fromLTRB(0.0, 5, 0.0, 5),
        child:
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.light_mode, color: Colors.deepPurple[100],),
            SizedBox(width: 15,),
            Expanded(
              child: Text(
                "$name",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.deepPurple[100],
                ),
              ),
            ),

            switchh(check, id, i)

          ],
        ),


      );
  }

  void curtains_ids(int id, String i) {
    databaseReference.child(userID).child("modus").child(i).child("ids").child(
        id.toString()).update({
      "curtains": 1,

    }).then((value) {
      databaseReference.child(userID).child("modus").child(i).update({
        "curtains": 1,
      });
    });
  }

  void lights_ids(int id, String i) {
    databaseReference.child(userID).child("modus").child(i).child("ids").child(
        id.toString()).update({
      "lights": 1,

    }).then((value) {
      databaseReference.child(userID).child("modus").child(i).update({
        "lights": 1,
      });
    });
  }

  void curtains_ids_delete(int id, String i) {
    databaseReference.child(userID).child("modus").child(i).child("ids").child(
        id.toString()).child("curtains")
        .remove().then((value) {
      String j = "1";
      FirebaseDatabase.instance
          .ref(userID)
          .child("modus")
          .child(i)
          .child("ids")
          .onValue
          .listen((event) {
        event.snapshot.children.forEach((element) {
          element.children.forEach((element2) {
            String jj = element2.key.toString();
            if (jj == "curtains") {
              j = jj;
            }
          });
        });
        if (j == "1") {
          databaseReference.child(userID).child("modus").child(i).child(
              "curtains").remove();
        }
      });
    });
  }

  void lights_ids_delete(int id, String i) {
    databaseReference.child(userID).child("modus").child(i).child("ids").child(
        id.toString()).child("lights")
        .remove().then((value) {
      String j = "1";
      FirebaseDatabase.instance
          .ref(userID)
          .child("modus")
          .child(i)
          .child("ids")
          .onValue
          .listen((event) {
        event.snapshot.children.forEach((element) {
          element.children.forEach((element2) {
            String jj = element2.key.toString();
            if (jj == "lights") {
              j = jj;
            }
          });
        });
        if (j == "1") {
          databaseReference.child(userID).child("modus").child(i).child(
              "lights").remove();
        }
      });
    });
  }

  Zeit(BuildContext context, String i, String name, TimeOfDay time,String start,String stop) async {
    await internet();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: time,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "${name} Time",


    );
    _timer?.cancel();
    await EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
    if(connected){
      if (timeOfDay != null && timeOfDay != time) {
        setState(() {
          time = timeOfDay;
          databaseReference.child(userID).child("modus").child(i).child(
              "${name}stunde").set(time.hour);
          databaseReference.child(userID).child("modus").child(i).child(
              "${name}minute").set(time.minute);
          FirebaseDatabase.instance
              .ref(userID)
              .child("modus")
              .child(i)
              .child("ids")
              .onValue
              .listen((event) {
            event.snapshot.children.forEach((element) {
              String j = element.key.toString();
              element.children.forEach((element2) {
                String jj = element2.key.toString();
                if (jj == "curtains") {
                  databaseReference.child(userID).child("curtains")
                      .child(j)
                      .child("${name}stunde")
                      .set(time.hour);
                  databaseReference.child(userID).child("curtains")
                      .child(j)
                      .child("${name}minute")
                      .set(time.minute);
                } else if (jj == "lights") {
                  if (name == "links") {
                    databaseReference.child(userID).child("lights").child(j)
                        .child("${start}stunde")
                        .set(time.hour);
                    databaseReference.child(userID).child("lights").child(j)
                        .child("${start}minute")
                        .set(time.minute);
                  }
                  if (name == "rechts") {
                    databaseReference.child(userID).child("lights")
                        .child(j)
                        .child("${stop}stunde")
                        .set(time.hour);
                    databaseReference.child(userID).child("lights")
                        .child(j)
                        .child("${stop}minute")
                        .set(time.minute);
                  }
                }
              });
            });
          });
        });
      }
    }else{
      EasyLoading.showError('kein Internet Verbindung');
    }

    EasyLoading.dismiss();
  }
  Future<void> loeschen(BuildContext context,String name,String i) {
    final _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
              title: Text('Wollen Sie $name wircklich löschen?'),

              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      FlatButton(
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Nein'),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                      FlatButton(
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text('Ja'),
                        onPressed: () async {
                          await internet();
                          _timer?.cancel();
                          await EasyLoading.show(
                            status: 'loading...',
                            maskType: EasyLoadingMaskType.black,
                          );

                          setState(() {

                            if(connected){

                              removemodus(i);
                              Navigator.pop(context);

                            }else{
                              EasyLoading.showError('kein Internet Verbindung');
                            }


                            if (_key.currentState!.validate()) {}
                          });
                          EasyLoading.dismiss();
                        },
                      ),
                    ],
                  ),
                ),

              ],
            ),
          );
        });
  }
  SizedBox switchbutton(bool boolean, String i, String name,void Function(void Function()) setState) {
    return SizedBox(
      height: 35,
      width: 75,
      child: StatefulBuilder(
          builder: (context, setState) {
            return Switch(
              activeColor: Colors.cyan[800],


              //initial value

              value: boolean,

              onChanged: (value) async {
                await internet();
                _timer?.cancel();
                await EasyLoading.show(
                  status: 'loading...',
                  maskType: EasyLoadingMaskType.black,
                );
                if(connected){
                  setState(() {
                    boolean = value;
                    int val = (boolean) ? 1 : 0;
                    databaseReference.child(userID).child("modus").child(i).child(
                        name.toString()).set(val);
                    if(name =="rechts"){
                      if(boolean){
                        databaseReference.child(userID).child("modus").child(i).child("links").set(0);
                      }else{
                        databaseReference.child(userID).child("modus").child(i).child("links").set(1);
                      }

                    }
                    var t = FirebaseDatabase.instance
                        .ref(userID)
                        .child("modus")
                        .child(i)
                        .child("ids")
                        .onValue
                        .listen((event) {
                      event.snapshot.children.forEach((element) {
                        String j = element.key.toString();
                        element.children.forEach((element2) {
                          String jj = element2.key.toString();
                          if (jj == "curtains") {
                            if(name =="rechts"){
                              if(boolean){
                                databaseReference.child(userID).child("curtains").child(j).child("links").set(0);
                              }else{
                                databaseReference.child(userID).child("curtains").child(j).child("links").set(1);
                              }

                            }

                            databaseReference.child(userID).child("curtains").child(j)
                                .child(name.toString())
                                .set(val);
                          } else if (jj == "lights") {
                            if (name == "motoron") {
                              databaseReference.child(userID).child("lights").child(j)
                                  .child("onoff")
                                  .set(val);
                            } else if (name == "motortimer") {
                              databaseReference.child(userID).child("lights").child(j)
                                  .child("timeraktiv")
                                  .set(val);
                            }
                          }
                        });
                      });
                    });
                  });
                }else{

                  EasyLoading.showError('kein Internet Verbindung');
                }
                EasyLoading.dismiss();
              },

            );}
      ),

    );
  }

  SizedBox switchh(bool boolean, int id, String i) {
    return SizedBox(
      height: 35,
      width: 75,
      child: StatefulBuilder(
          builder: (context, setState) {
        return Switch(
          activeColor: Colors.cyan[800],

          //initial value
          value: boolean,
          onChanged: (value) async {
            await internet();
            _timer?.cancel();
            await EasyLoading.show(
              status: 'loading...',
              maskType: EasyLoadingMaskType.black,
            );
            if(connected){
              setState(() {
                boolean = value;
                if (boolean) {
                  lights_ids(id, i);
                  update_geraete_liste(i);
                } else {
                  lights_ids_delete(id, i);
                  update_geraete_liste(i);
                }
              });
            }else{
              EasyLoading.showError('kein Internet Verbindung');
            }

            EasyLoading.dismiss();
          },

        );}
      ),
    );
  }

  SizedBox switchhh(bool boolean, int id, String i) {

    return SizedBox(
      height: 35,
      width: 75,
      child: StatefulBuilder(
          builder: (context, setState) {
        return Switch(
          activeColor: Colors.cyan[800],
          //initial value

          value: boolean,

          onChanged: (value) async {
            await internet();
            _timer?.cancel();
            await EasyLoading.show(
              status: 'loading...',
              maskType: EasyLoadingMaskType.black,
            );
            if(connected){
              setState(() {
                boolean = value;
                if (boolean) {
                  curtains_ids(id, i);
                  update_geraete_liste(i);
                } else {
                  curtains_ids_delete(id, i);
                  update_geraete_liste(i);
                }
              });
            }else{
              EasyLoading.showError('kein Internet Verbindung');
            }

            EasyLoading.dismiss();
          },

        );}
      ),
    );
  }

  removemodus(String i) {
    databaseReference.child(userID).child("modus").child(i).remove();
  }

  update_geraete_liste(String i) async {
    DataSnapshot snapshot = await databaseReference.child(userID).get();

     FirebaseDatabase.instance
        .ref(userID)
        .child("curtains")
        .onValue
        .listen((event) {
       if (geraetelist.isNotEmpty) {
         geraetelist.clear();
       }
      for (var element in event.snapshot.children) {

        var k = element.key;
         geraetelist.add(curtains_namen((snapshot
            .child("curtains")
            .child(k.toString())
            .child("curtains_name")
            .value).toString(),
            int.tryParse(k.toString()) ?? 0,
            i,
            snapshot
                .child("modus")
                .child(i)
                .child("ids")
                .child(k.toString())
                .child("curtains")
                .exists
        ));
      }
    });
    FirebaseDatabase.instance
        .ref(userID)
        .child("lights")
        .onValue
        .listen((event) {
      if (geraetelist2.isNotEmpty) {
        geraetelist2.clear();
      }
      //geraetelist.removeRange((count+1),(geraetelist.length));
      for (var element in event.snapshot.children) {

        var k = element.key;

        geraetelist2.add(lights_namen((snapshot
            .child("lights")
            .child(k.toString())
            .child("lights_name")
            .value).toString(),
            int.tryParse(k.toString()) ?? 0,
            i,
            snapshot
                .child("modus")
                .child(i)
                .child("ids")
                .child(k.toString())
                .child("lights")
                .exists
        ));


      }

    });

  }
}