

import 'dart:async';


import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';


import 'package:flutter/material.dart';

import 'dart:math';
import 'package:provider/provider.dart';
import 'package:smart_home/authentication_screens/auth.dart';
import 'package:smart_home/authentication_screens/login.dart';

import 'package:smart_home/lights.dart';
import 'package:smart_home/curtains.dart';
import 'package:smart_home/configuration.dart';
import 'package:smart_home/modus.dart';







Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();




  runApp(MyApp());
  configLoading();
}
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
    //..customAnimation = CustomAnimation();
}


class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService?>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges, initialData: null,
        ),
      ],
      child: MaterialApp(

        debugShowCheckedModeBanner:false,
        home: AuthWrapper(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget{
  @override
  Widget build(BuildContext context)
  {
    final user = context.watch<User?>();

    if(user != null){
      return Main();

    }
    return Login();
  }


}

class Main extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark,
      routes: {
        '/Lights': (context) =>  Lights(),
        '/Curtains': (context) =>  Curtains(),
        '/Configuration': (context) =>  Configuration(),
        '/Modus': (context) =>  Modus(),

      },
      home: Slide(),
    );
  }
}

class Slide extends StatefulWidget {
  const Slide({Key? key}) : super(key: key);

  @override
  State<Slide> createState() => _SlideState();
}

class _SlideState extends State<Slide> {
  double value = 0;
  String userID ="";
  String db_email="";

  getData ()async {
    User? user =  FirebaseAuth.instance.currentUser;
    userID = user!.uid;
    await FirebaseFirestore.instance.collection("user").doc(user.uid).get().then((db){

      return [
        db.data()!['email']== null ? db_email = "" : db_email = db.data()!['email'] ,
      ];

    });

    if (!mounted) return;
  }

  final _normalStyle = TextStyle(
    color: Colors.black,
    fontSize: 24,
  );
  final _normalcolor = Colors.black;
  final _stylecolor = Colors.grey;
  final _redStyle = TextStyle(
    color: Colors.grey,
    fontSize: 24,
  );
  int redIndex = 0;

  Timer? timer1;
  Timer? timer2;
  @override
  void initState() {
    super.initState();
    getData();
    timer2 = Timer.periodic(Duration(seconds: 3), (timer2) {
      setState(() {
        redIndex =0;
        timer1 = Timer.periodic(Duration(milliseconds: 50), (timer1) {
          setState(() {
            redIndex++;
            if (redIndex > 19) timer1.cancel();
          });

        });
      });

    });

  }

  @override
  void dispose() {
    timer1!.cancel();
    timer2!.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.grey.shade800,Colors.grey.shade500,],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )
            ),
          ),
          SafeArea(
              child: Container(
                  width: 200.0,
                  padding: EdgeInsets.all(8.0),
                  child:ListView(
                      children: [
                        Text(
                          'Hi,',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          db_email,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "userID:",
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                              child:
                              Text(
                                userID,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                _copyText();
                              },
                            ),
                        SizedBox(
                          height: 25,
                        ),

                        ListTile(
                          onTap: () {
                            Navigator.pushNamed(context, '/Configuration');
                          },
                          leading: Icon(
                            Icons.info,
                            color: Colors.amber,
                          ),
                          title: Text(
                            "Configuration",
                            style: TextStyle(color: Colors.amber),
                          ),
                        ),

                        SizedBox(
                          height:100,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(

                                height: 45,
                                width: 140,
                                decoration: BoxDecoration(
                                    color: Colors.deepPurple[400],
                                    borderRadius: BorderRadius.circular(20)),
                                child: TextButton(
                                  onPressed: () {
                                    context.read<AuthService>().signOut();
                                  },
                                  child: Text(
                                    'Ausloggen',
                                    style: TextStyle(color: Colors.white, fontSize: 25),
                                  ),
                                ),
                              ),
                            ]
                        ),
                        SizedBox(
                          height:100,
                        ),]
                  )
              )
          ),
          TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: value),
              duration: Duration(milliseconds: 500),
              builder: (_, double val, __) {
                return (Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..setEntry(0, 3, 200 * val)
                    ..rotateY((pi / 6) * val),
                  child: Scaffold(
                      appBar: AppBar(

                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.deepPurple[400],

                        title: Text(
                          'Smart Home',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Colors.white,
                          ),
                        ),
                        centerTitle: true,





                      ),
                      body:Padding(
                        padding: const EdgeInsets.fromLTRB(15, 75, 15, 15),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [


                              SizedBox(
                                height:130,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/Modus');
                                  },

                                  child: Container(

                                    decoration: BoxDecoration(
                                        //color: Colors.deepPurple[400],
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
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.palette,
                                                  color: Colors.deepPurple[100],
                                                  size: 30,
                                                ),
                                              ],),
                                          ),

                                          Center(
                                            child: Text("Modus",textAlign: TextAlign.center,style: TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                              color: Colors.deepPurple[100],
                                            ),),
                                          ),











                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25,),
                              SizedBox(
                                height:130,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/Lights');
                                  },

                                  child: Container(
                                    decoration: BoxDecoration(
                                        //color: Colors.deepPurple.shade400,
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
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.light_mode_sharp,
                                                  color: Colors.deepPurple[100],
                                                  size: 30,
                                                ),
                                              ],),
                                          ),

                                          Center(
                                            child: Text("Lights",textAlign: TextAlign.center,style: TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                              color: Colors.deepPurple[100],
                                            ),),
                                          ),









                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25,),
                              SizedBox(
                                height:130,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/Curtains');
                                  },

                                  child: Container(
                                    decoration: BoxDecoration(
                                        //color: Colors.deepPurple.shade400,
                                        border: Border.all(
                                          width: 2.0,
                                          color:Colors.cyan.shade800,
                                        ),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(5, 12, 0, 0),
                                      child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.center,

                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0,0,0,0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.curtains,
                                                  color: Colors.deepPurple[100],
                                                  size: 30,
                                                ),
                                              ],),
                                          ),

                                          Center(
                                            child: Text("Curtains",textAlign: TextAlign.center,style: TextStyle(
                                              fontSize: 30.0,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2.0,
                                              color: Colors.deepPurple[100],
                                            ),),
                                          ),









                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 75,),

                              SizedBox(
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                                  child: Container(

                                    child: Center(
                                      child: Text.rich(
                                        TextSpan(children: [
                                          WidgetSpan(
                                            child: Icon( Icons.arrow_forward,
                                              color: redIndex == 1 ? _stylecolor : _normalcolor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: " N",
                                            style: redIndex == 2 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "a",
                                            style: redIndex == 3 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "c",
                                            style: redIndex == 4 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "h",
                                            style: redIndex == 5 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: " R",
                                            style: redIndex == 6 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "e",
                                            style: redIndex == 7 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "c",
                                            style: redIndex == 8 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "h",
                                            style: redIndex == 9 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "t",
                                            style: redIndex == 10 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "s",
                                            style: redIndex == 11 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: " S",
                                            style: redIndex == 12 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "c",
                                            style: redIndex == 13 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "h",
                                            style: redIndex == 14 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "i",
                                            style: redIndex == 15 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "e",
                                            style: redIndex == 16 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "b",
                                            style: redIndex == 17 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "e",
                                            style: redIndex == 18 ? _redStyle : _normalStyle,
                                          ),
                                          TextSpan(
                                            text: "n",
                                            style: redIndex == 19 ? _redStyle : _normalStyle,
                                          ),


                                        ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      )
                  ),
                ));
              }),
          GestureDetector(onHorizontalDragUpdate: (e) {
            if (e.delta.dx > 0) {
              setState(() {
                value = 1;
              });
            } else {
              setState(() {
                value = 0;
              });
            }
          }
          )
        ],
      ),
    );
  }
  void _copyText() {
    FlutterClipboard.copy(userID).then((value) {
      _showSnackBar();
    });
  }
  void _showSnackBar() {
    const snack =
    SnackBar(content: Text("userID kopiert"), duration: Duration(seconds: 2));
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}





