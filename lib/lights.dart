import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:smart_home/authentication_screens/auth.dart';
import 'package:asbool/asbool.dart';

class Lights extends StatefulWidget {
  Lights({Key? key}) : super(key: key);

  @override
  _LightsState createState() => _LightsState();
}
class _LightsState extends State<Lights> {
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<Widget> _cardList = [];
  String userID ="";
  int AnzahlLights = 0;
  int AnzahlCurtains = 0;
  int AnzahlModus = 0;
  TimeOfDay starttime = TimeOfDay.now();
  TimeOfDay stoptime = TimeOfDay.now();
  TextEditingController name = TextEditingController();
  Timer? _timer;
  bool connected = false;

  @override
  initState() {
    super.initState();
    onchanged();
    internet();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });

    //if (!mounted) return;
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
          IconButton(onPressed: (){name_eingeben(context);}, icon: Icon(Icons.add)),
        ],
        backgroundColor: Colors.deepPurple[400],
        title: Text(
          'Lights',
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
                child:
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.94,
                  ),
                  itemCount: _cardList.length,
                  itemBuilder: (context,index){
                    return
                      _cardList[index];
                  }, ),


              );
            } else {
              return Center(child: CircularProgressIndicator(
                color: Colors.grey,
                backgroundColor: Colors.white,
              ));}}),

    );
  }

  Widget test(String i,
      String name,
      bool onoff,
      bool timeraktiv,
      int startstunde,
      int startminute,
      int stopstunde,
      int stopminute,
      ValueNotifier<Color> colors) {
    return Padding(
      padding:  EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            popwidget(context, i, name, onoff,
                timeraktiv, startstunde, startminute,
                stopstunde, stopminute, colors);
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
                      Icons.light_mode_sharp,
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

                    switchbutton(onoff, i, "onoff",setState),
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
  onchanged(){
    databaseReference
        .child(userID)
        .onValue.listen((event) {

        getData();




    });

  }

  void _addCardWidget() {
    setState(() {
      AnzahlLights++;
      databaseReference.child(userID).child("lights").child(AnzahlLights.toString()).update({
        "lights_name":name.text,
        "red":0,
        "green":0,
        "blue":0,
        "helligkeit":0,
        "onoff":0,
        "timeraktiv":0,
        "startstunde":0,
        "stopstunde":0,
        "startminute":0,
        "stopminute":0,
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
      userID,
    );
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



    FirebaseDatabase.instance.ref(userID).child("lights").onValue.listen((event) {
      if(_cardList.isNotEmpty){
        _cardList.clear();
      }

      for (var element in event.snapshot.children) {
        if (!mounted) return;
        var i = element.key;
        _cardList.add(test(i.toString(),
          (snapshot.child("lights").child(i.toString()).child("lights_name").value).toString(),
          asBool(int.tryParse((snapshot.child("lights").child(i.toString()).child("onoff").value).toString() )?? 0),
          asBool(int.tryParse((snapshot.child("lights").child(i.toString()).child("timeraktiv").value).toString() )?? 0),
          int.tryParse((snapshot.child("lights").child(i.toString()).child("startstunde").value).toString()) ?? 0,
          int.tryParse((snapshot.child("lights").child(i.toString()).child("startminute").value).toString())?? 0,
          int.tryParse((snapshot.child("lights").child(i.toString()).child("stopstunde").value).toString())?? 0,
          int.tryParse((snapshot.child("lights").child(i.toString()).child("stopminute").value).toString())?? 0,
          ValueNotifier<Color>(Color.fromARGB(
            int.tryParse((snapshot.child("lights").child(i.toString()).child("helligkeit").value).toString())?? 0,
            int.tryParse((snapshot.child("lights").child(i.toString()).child("red").value).toString())?? 0,
            int.tryParse((snapshot.child("lights").child(i.toString()).child("green").value).toString())?? 0,
            int.tryParse((snapshot.child("lights").child(i.toString()).child("blue").value).toString())?? 0,
          ),
          ),
        ));


      }

    });
    if (!mounted) return;
    setState((){

    });




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

  Future<void> popwidget(BuildContext context,String i,
      String name,
      bool onoff,
      bool timeraktiv,
     int startstunde,
    int startminute,
       int stopstunde,
      int stopminute,
      ValueNotifier<Color> colors)  {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Column(
                    children: [
                      Text("Lights ID: $i"),
                      Text("Name: $name",textAlign: TextAlign.center,style: TextStyle(
                          fontSize: 20
                      ),),
                    ],
                  ),
                  content:Container(
                    width: double.minPositive,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Timer"),
                              switchbutton(timeraktiv, i, "timeraktiv",setState),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                  onPressed: () async{
                                    await  Zeit(context, i, "start", starttime);
                                    DataSnapshot snapshot = await databaseReference.child(userID).get();
                                    setState((){
                                      startminute= int.parse((snapshot.child("lights").child(i).child("startminute").value)
                                          .toString());
                                      startstunde= int.parse((snapshot.child("lights").child(i).child("startstunde").value)
                                          .toString());
                                      timeraktiv =asBool(int.tryParse((snapshot.child("lights").child(i).child("timeraktiv").value).toString() )?? 0);
                                    });

                                  },
                                  child: Text("Start",style: TextStyle(color: Colors.amber[500]))),
                              Text("${startstunde}:${startminute}"),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              TextButton(
                                  onPressed: () async{
                                    await Zeit(context, i, "stop", stoptime);
                                    DataSnapshot snapshot = await databaseReference.child(userID).get();
                                    setState((){
                                      stopminute= int.parse((snapshot.child("lights").child(i).child("stopminute").value)
                                          .toString());
                                      stopstunde= int.parse((snapshot.child("lights").child(i).child("stopstunde").value)
                                          .toString());
                                      timeraktiv =asBool(int.tryParse((snapshot.child("lights").child(i).child("timeraktiv").value).toString() )?? 0);
                                    });

                                  },
                                  child: Text("Stop",style: TextStyle(color: Colors.amber[500]))),
                              Text("${stopstunde}:${stopminute}"),
                            ],
                          ),
                          Container(
                            child: ValueListenableBuilder<Color>(
                              valueListenable: colors,
                              builder: (_, colors, __) {
                                return Column(
                                  children: [
                                    ColorPicker(
                                        color: colors,

                                        onChanged: (value) {
                                          colors = value;
                                          //verify(ValueNotifier<Color>(colors), i);
                                        }
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
          );

        });
  }
  Zeit(BuildContext context,String i,String name, TimeOfDay time) async {
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
      if(timeOfDay != null && timeOfDay != time)
      {


        setState(() {
          time = timeOfDay;
          databaseReference.child(userID).child("lights").child(i).child("${name}stunde").set(time.hour);
          databaseReference.child(userID).child("lights").child(i).child("${name}minute").set(time.minute);

        });
      }
    }else{
      EasyLoading.showError('kein Internet Verbindung');
    }

    EasyLoading.dismiss();
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
                                databaseReference.child(userID).child("lights").child(i.toString()).update({
                                  "lights_name": namee,
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

                              removelights(i);
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
                  setState(()  {
                    boolean = value;
                    int val = (boolean) ? 1 : 0;
                    databaseReference.child(userID).child("lights").child(i).child(name).set(val);
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
  verify(ValueNotifier<Color> colors, String i) async{
    await internet();
    double red = colors.value.red.toDouble();
    double green = colors.value.green.toDouble();
    double blue = colors.value.blue.toDouble();
    double opacity = colors.value.opacity;
    int alpha = colors.value.alpha;
    int edit_red =(red*opacity).toInt();
    int edit_green =(green*opacity).toInt();
    int edit_blue= (blue*opacity).toInt();
    if(connected){
      databaseReference.child(userID).child("lights").child(i).child("red").set(edit_red);
      databaseReference.child(userID).child("lights").child(i).child("green").set(edit_green);
      databaseReference.child(userID).child("lights").child(i).child("blue").set(edit_blue);
      databaseReference.child(userID).child("lights").child(i).child("helligkeit").set(alpha);
    }else{
      EasyLoading.showError('kein Internet Verbindung');
    }


  }
  removelights(String i){


    databaseReference.child(userID).child("lights").child(i).remove();
    lights_ids_delete(i);

  }
  void lights_ids_delete(String i) {
    FirebaseDatabase.instance.ref(userID).child("modus").onValue.listen((event) {


      for (var element in event.snapshot.children) {
        if (!mounted) return;
        var k = element.key;
        databaseReference.child(userID).child("modus").child(k.toString()).child("ids")
            .child(i).child("lights")
            .remove()
            .then((value) {
          String j = "1";
          FirebaseDatabase.instance
              .ref(userID)
              .child("modus")
              .child(k.toString())
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
              databaseReference.child(userID).child("modus").child(k.toString()).child(
                  "lights").remove();
            }
          });
        });
      }});

  }
}