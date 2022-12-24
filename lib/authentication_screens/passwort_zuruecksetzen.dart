
import 'package:flutter/material.dart';

import 'package:provider/src/provider.dart';

import 'package:smart_home/authentication_screens/auth.dart';




class passwortvergessen extends StatefulWidget {
  const passwortvergessen({Key? key}) : super(key: key);

  @override
  _passwortvergessenState createState() => _passwortvergessenState();
}

class _passwortvergessenState extends State<passwortvergessen> {

  TextEditingController emailController = TextEditingController();
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(


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
      body: Form(
        key: _key,
        child: Container(
          color: Colors.grey[900],


          child: ListView(
              children: [

                Padding(
                  padding: const EdgeInsets.all(12.0),

                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding:
                        EdgeInsets.all(25.0),
                        child: Text(
                          'Welcome to Your Smart Home',
                          style: TextStyle(
                            shadows: [
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black,
                              ),
                            ],
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,

                            color: Colors.deepPurple.shade400,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(25.0),
                        //padding: EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Dieses Field kann nicht leer sein.';
                            } else if (!emailController.text.contains("@") || !emailController.text.contains(".")){
                              return 'E-mail muss in folgendes Form sein: username@---.---';
                            }
                            return null;
                          },

                          controller: emailController,
                          style: TextStyle(
                            color: Colors.white,
                          ),

                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Colors.deepPurple.shade400, width: 2.0),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'E-mail',
                              labelStyle:
                              TextStyle(fontSize: 19.0, color: Colors.white),
                              hintText: 'E-Mail-Adresse wie z.B. (name@gmail.de)',
                              hintStyle: TextStyle(color: Colors.white),
                              filled: true),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple[400],
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(

                          onPressed: () {
                            final String email = emailController.text.trim();
                            context.read<AuthService>().passwort(
                              email,
                            );
                            if (_key.currentState!.validate()) {
                            }

                          },
                          child: Text(
                            'Zuruecksetzen',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),



                    ],
                  ),

                ),]
          ),
        ),
      ),

    );
  }
}