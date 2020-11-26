import 'package:cab_driver/widgets/TaxiButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SignOutTab extends StatelessWidget {

  FirebaseAuth mauth = FirebaseAuth.instance;



  @override
  Widget build(BuildContext context) {
    return Center(child:
    TaxiButton(title:'Ratings Tab',
              onPressed: (){
      mauth.signOut();
      },

    ));
  }
}
