import 'dart:async';
import 'dart:io';
import 'package:asbool/asbool.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:smart_home/authentication_screens/auth.dart';


class Curtains extends StatefulWidget {
  Curtains({Key? key}) : super(key: key);

  @override
  _CurtainsState createState() => _CurtainsState();
}

class _CurtainsState extends State<Curtains> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Widget> _cardList = [];

  String userID = "";
  int AnzahlLights = 0;
  int AnzahlCurtains = 0;
  int AnzahlModus = 0;
  bool connected = false;

  TimeOfDay rechtstime = TimeOfDay.now();
  TimeOfDay linkstime = TimeOfDay.now();
  Timer? _timer;

  TextEditingController name = TextEditingController();

  @override
  initState() {
    super.initState();
    getData();
    internet();
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
        actions: [
          IconButton(
              onPressed: () {
                name_eingeben(context);
              },
              icon: Icon(Icons.add))
        ],
        backgroundColor: Colors.deepPurple[400],
        title: Text(
          'Curtains',
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
                delay: Duration(microseconds: 10),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.94,
                  ),
                  itemCount: _cardList.length,
                  itemBuilder: (context, index) {
                    return _cardList[index];
                  },
                ),
              );

            } else {
              return Center(child: CircularProgressIndicator(
                color: Colors.grey,
                backgroundColor: Colors.white,
              ));}}),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _addCardWidget() {
    internet();
    if(connected){

      setState(() {
        AnzahlCurtains++;
        databaseReference.child(userID).child("curtains").child(AnzahlCurtains.toString()).update({
          "curtains_name": name.text,
          "linksstunde": 0,
          "linksminute": 0,
          "rechtsstunde": 0,
          "rechtsminute": 0,
          "links": 0,
          "rechts": 0,
          "motoron": 0,
          "motortimer": 0,
        });
        Update(context);
        Timer(Duration(microseconds: 50), () {
          getData();
        });
      });
    }

  }

  Update(BuildContext context) {
    DatabaseManager()
        .updateUserList(AnzahlLights, AnzahlCurtains, AnzahlModus, userID);
  }
  getData() async{

    User? user =  FirebaseAuth.instance.currentUser;
    userID = user!.uid;
    DataSnapshot snapshot =  await databaseReference.child(userID).get();


    await FirebaseFirestore.instance.collection("user").doc(user.uid).get().then((db){

      return [
        db.data()!['AnzahlLights']== null ? AnzahlLights = 0 : AnzahlLights = db.data()!['AnzahlLights'] ,
        db.data()!['AnzahlCurtains']== null ? AnzahlCurtains = 0 : AnzahlCurtains = db.data()!['AnzahlCurtains'] ,
        db.data()!['AnzahlModus']== null ? AnzahlModus = 0 : AnzahlModus = db.data()!['AnzahlModus'] ,
      ];

    });



    FirebaseDatabase.instance.ref(userID).child("curtains").onValue.listen((event) {

      if(_cardList.isNotEmpty){
        _cardList.clear();
      }

      for (var element in event.snapshot.children) {
        //if (!mounted) return;
        var i = element.key;

        _cardList.add(_card(i.toString(),
          (snapshot.child("curtains").child(i.toString()).child("curtains_name").value).toString(),
          asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("motoron").value).toString() )?? 0),
          asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("motortimer").value).toString() )?? 0),
          asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("rechts").value).toString() )?? 0),
          asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("links").value).toString() )?? 0),
          int.tryParse((snapshot.child("curtains").child(i.toString()).child("rechtsstunde").value).toString()) ?? 0,
          int.tryParse((snapshot.child("curtains").child(i.toString()).child("rechtsminute").value).toString())?? 0,
          int.tryParse((snapshot.child("curtains").child(i.toString()).child("linksstunde").value).toString())?? 0,
          int.tryParse((snapshot.child("curtains").child(i.toString()).child("linksminute").value).toString())?? 0,

        ));


      }

    });
    if (!mounted) return;
    setState((){

    });




  }

  Widget _card(
      String i,
      String name,
      bool motoron,
      bool motortimer,
      bool rechts,
      bool links,
      int rechtsstunde,
      int rechtsminute,
      int linksstunde,
      int linksminute,
      ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
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
            );
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
                    Icons.curtains,
                    color: Colors.deepPurple[100],
                    size: 30,
                  ),
                ],),
                       SizedBox(
                         height: 20,
                       ),
                       Text(name,textAlign: TextAlign.center,style: TextStyle(fontSize: 18,color: Colors.deepPurple[200],),),
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
               ],)

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> name_eingeben(BuildContext context) {

    final _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
              title: Text('Bitte geben Sie einen Name:'),
              content:
                  TextFormField(
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
                                databaseReference.child(userID).child("curtains").child(i.toString()).update({
                                  "curtains_name": namee,
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

                              removecurtains(i);
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

  Future popwidget(
      BuildContext context,
      String i,
      String name,
      bool motoron,
      bool motortimer,
      bool rechts,
      bool links,
      int rechtsstunde,
      int rechtsminute,
      int linksstunde,
      int linksminute,
      ) {
    return showDialog(
        context: context,
        builder: (context) {
          return
               StatefulBuilder(
                 builder: (context,setState) {
                   return AlertDialog(
                    title: Column(
                      children: [
                        Text("Curtains ID: $i"),
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

                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Timer"),
                                switchbutton(motortimer, i, "motortimer",setState),
                              ],
                            ),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                    onPressed: () async{
                                      await Zeit(context, i, "rechts", rechtstime,setState);
                                      DataSnapshot snapshot = await databaseReference.child(userID).get();
                                      setState((){
                                        rechtsminute= int.parse((snapshot.child("curtains").child(i).child("rechtsminute").value)
                                            .toString());
                                        rechtsstunde= int.parse((snapshot.child("curtains").child(i).child("rechtsstunde").value)
                                            .toString());
                                        rechts = asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("rechts").value).toString() )?? 0);
                                        links = asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("links").value).toString() )?? 0);
                                        motortimer =asBool(int.tryParse((snapshot.child("curtains").child(i).child("motortimer").value).toString() )?? 0);
                                      });


                                    },
                                    child: Text("Rechts",style: TextStyle(color: Colors.amber[500]))),
                                Text("${rechtsstunde}:${rechtsminute}"),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                    onPressed: () async{
                                      await Zeit(context, i, "links", linkstime,setState);
                                      DataSnapshot snapshot = await databaseReference.child(userID).get();
                                      setState((){
                                        linksminute= int.parse((snapshot.child("curtains").child(i).child("linksminute").value)
                                            .toString());
                                        linksstunde= int.parse((snapshot.child("curtains").child(i).child("linksstunde").value)
                                            .toString());
                                        rechts = asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("rechts").value).toString() )?? 0);
                                        links = asBool(int.tryParse((snapshot.child("curtains").child(i.toString()).child("links").value).toString() )?? 0);
                                        motortimer =asBool(int.tryParse((snapshot.child("curtains").child(i).child("motortimer").value).toString() )?? 0);
                                      });

                                    },
                                    child: Text("  Links  ",style: TextStyle(color: Colors.amber[500]))),
                                Text(" ${linksstunde}:${linksminute}"),
                              ],
                            ),

                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Links"),
                                switchbutton(rechts, i,"rechts",setState),
                                Text("Rechts"),
                              ],
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

                              child: Text('Bearbeiten',style: TextStyle(color: Colors.amber[500])),
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
                 }
               );}
          );

  }



  Zeit(BuildContext context, String i, String name, TimeOfDay time,void Function(void Function()) setState) async {
    await internet();
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: time,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "${name}",
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
          databaseReference
              .child(userID)
              .child("curtains")
              .child(i)
              .child("${name}stunde")
              .set(time.hour);
          databaseReference
              .child(userID)
              .child("curtains")
              .child(i)
              .child("${name}minute")
              .set(time.minute);


        });
      }

    }else{
      EasyLoading.showError('kein Internet Verbindung');
    }

    EasyLoading.dismiss();
  }


   SizedBox switchbutton(bool boolean, String i, String name,void Function(void Function()) setState) {
    return SizedBox(
      height: 35,
      width: 75,
      child: StatefulBuilder(
          builder: (context, setState) {
        return Switch(
          //initial value
          activeColor: Colors.cyan[800],
          value: boolean,

          onChanged: (value) async {
            await internet();
            _timer?.cancel();
            await EasyLoading.show(
              status: 'loading...',
              maskType: EasyLoadingMaskType.black,
            );
            if(connected){
              if (!mounted) return;
                setState(()  {
                  boolean = value;
                  int val = (boolean) ? 1 : 0;
                  databaseReference.child(userID).child("curtains").child(i).child(name).set(val);
                  if(name =="rechts"){
                    if(boolean){
                      databaseReference.child(userID).child("curtains").child(i).child("links").set(0);
                    }else{
                      databaseReference.child(userID).child("curtains").child(i).child("links").set(1);
                    }

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
  removecurtains(String i){


    databaseReference.child(userID).child("curtains").child(i).remove();
    curtains_ids_delete(i);

  }
  void curtains_ids_delete(String i) {

    FirebaseDatabase.instance.ref(userID).child("modus").onValue.listen((event) {


      for (var element in event.snapshot.children) {
        if (!mounted) return;
        var k = element.key;
        databaseReference.child(userID).child("modus").child(k.toString()).child("ids").child(i).child("curtains")
            .remove().then((value) {
          String j = "1";
          FirebaseDatabase.instance.ref(userID).child("modus").child(k.toString()).child("ids").onValue.listen((event) {
            event.snapshot.children.forEach((element) {

              element.children.forEach((element2) {
                String jj = element2.key.toString();
                if(jj == "curtains") {
                  j=jj;
                }
              });

            });
            if(j == "1"){
              databaseReference.child(userID).child("modus").child(k.toString()).child("curtains").remove();
            }
          });
        });

      }

    });
  }

}
