import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'package:url_launcher/url_launcher.dart';


class Configuration extends StatefulWidget {
  const Configuration({Key? key}) : super(key: key);

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400],
        title: Text(
          'Configuration',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(15,15,8,8),
        child: SingleChildScrollView(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("1. Schließen Sie ihr Geräte an.",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Text("2. Öffnen Sie die smart Home-App und klicken Sie auf Curtains oder Lights, um die ID zu bekommen.",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/1.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/2.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Text("3. Merken Sie sowohl die ID für die hinzugefügte Gerät als auch die UserID (gedrückt halten um UserID zu kopieren).",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/3.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/4.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/5.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Text("4. Öffnen Sie Ihre WLAN-Einstellungen auf Ihrem Telefon oder Tablet,"
                  " auf dem die Smart Home-App installiert ist. Sie sollten ein neues WLAN „Smart_Home (curtains) oder Smart_Home (lights)“ sehen."
                  "Verbinden Sie sich mit diesem WLAN (Passwort ist die mitgelieferte Chip-ID).",style: TextStyle(fontSize: 15),),
              Center(
                child: Container(
                  width: 290,
                  height: 440,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/6.jpg",

                  ),
                ),
              ),

              Text("5. Öffnen Sie die Smart Home-App wieder und klicken Sie auf config per App oder config per Webseite.",style: TextStyle(fontSize: 15),),

              SizedBox(height: 15,),
              Text("6. Füllen Sie die Infos aus und klicken Sie auf fertig.",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: (){name_eingeben(context);}, child: Text("config per App",style: TextStyle(color: Colors.amber),)),
                ],
              ),

              Center(
                child: Container(
                  width: 290,
                  height: 400,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/9.jpg",

                  ),
                ),
              ),



              Text("7. Füllen Sie die Infos aus und klicken Sie auf Save.",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(onPressed: _launchURLApp, child: Text("config per Webseite",style: TextStyle(color: Colors.amber),)),
                ],
              ),              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/7.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Container(
                  width: 290,
                  height: 600,
                  //color: Colors.white,
                  child: Image.asset(
                    "assets/8.jpg",

                  ),
                ),
              ),
              SizedBox(height: 15,),
              Text("8. Wenn die WLAN-Verbindung automatisch verschwendet und das Gerät für 5 Sekunden blau leuchtet, "
                  "dann haben Sie die Configuration richtig ausgeführt.",style: TextStyle(fontSize: 15),),
              SizedBox(height: 15,),
              Text("9. Falls Sie Ihr Geräte erneut configurieren wollen, "
                  "weil Sie z.B. das Gerät aus versehen glöscht haben, "
                  "dann halten sie die Taste für 5 Sekunden gedruckt und Sie können die Schritte nochmal widerholen.",style: TextStyle(fontSize: 15),),

              SizedBox(height: 30,),





            ],
          ),
        ),
      )

    );
  }

  _launchURLApp() async {
    var url = Uri.parse("http://192.168.4.1/wifi?");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }



  Future<void> name_eingeben(BuildContext context) {
    TextEditingController ssid = TextEditingController();
    TextEditingController passwort = TextEditingController();
    TextEditingController uid = TextEditingController();
    TextEditingController nummer = TextEditingController();
    final _key = GlobalKey<FormState>();
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _key,
            child: AlertDialog(
              title: Text('Bitte geben Sie Ihre Daten:'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Dieses Field kann nicht leer sein.';
                        }
                        return null;
                      },
                      controller: ssid,
                      decoration: InputDecoration(hintText: "WLAN Name"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Dieses Field kann nicht leer sein.';
                        }
                        return null;
                      },
                      controller: passwort,
                      decoration: InputDecoration(hintText: "WLAN Passwort"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Dieses Field kann nicht leer sein.';
                        }
                        return null;
                      },
                      controller: uid,
                      decoration: InputDecoration(hintText: "User ID"),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Dieses Field kann nicht leer sein.';
                        }
                        return null;
                      },
                      controller: nummer,
                      decoration: InputDecoration(hintText: "Gerät ID"),
                    ),
                  ],
                ),
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
                        onPressed: ()  {


                          setState(() {

                            final String ssidd = ssid.text.trim();
                            final String passwortt = passwort.text.trim();
                            final String uidd = uid.text.trim();
                            final String nummerr = nummer.text.trim();


                              if (ssidd.isNotEmpty) {

                                save(ssidd,passwortt,uidd,nummerr);
                                Navigator.pop(context);

                              }



                            if (_key.currentState!.validate()) {}
                          });

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
  Future<http.Response> save(String ssid,String passwort,String uid,String nummer) {
    return http.post(
      Uri.parse('http://192.168.4.1/wifisave?s=${ssid}&p=${passwort}&s1=&p1=&key_text=${uid}&key_text2=${nummer}&ip=0.0.0.0&gw=192.168.2.1&sn=255.255.255.0'),

    );
  }
}

