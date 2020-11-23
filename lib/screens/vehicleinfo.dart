import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/screens/mainpage.dart';
import 'package:cab_driver/widgets/TaxiButton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfoPage extends StatelessWidget {

  static const String id = 'vehicleinfo';

  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();

  void updateProfile(context)
  {
    String id = currentFireBaseUser.uid;
    
    DatabaseReference driverRef = FirebaseDatabase.instance.reference().child('drivers/$id/vehicle_details');

    Map driverMap = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicleNumberController.text,
    };

    driverRef.set(driverMap);
    // Driver Registration is Successful
    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);




  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

              SizedBox(height: 20,),
              Image(
                image: AssetImage('images/logo.png'),
                height: 110,
                width: 110,
                 ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30,20,30,20),
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Text('Enter vehicle details',style: TextStyle(fontSize: 22,fontFamily: 'Brand-Bold'),),
                    SizedBox(height: 25,),
                    TextField(
                      controller: carModelController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car Model',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,

                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: carColorController,
                      //keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Car Color',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,

                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 10,),
                    TextField(
                      controller: vehicleNumberController,
                      maxLength: 11,
                    //  keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: 'Vehicle number',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,

                        ),
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 40,),

                    TaxiButton(
                      color: BrandColors.colorGreen,
                      title: 'PROCEED ',
                      onPressed: (){

                        if(carModelController.text.length < 3)
                          {
                            print('MODEL SAHI SE DAAL');
                            return;
                          }

                        if(carColorController.text.length < 3)
                        {
                          print('COLOR SAHI SE DAAL');
                          return;
                        }
                        if(vehicleNumberController.text.length < 3)
                        {
                          print('NUMBER SAHI SE DAAL');
                          return;
                        }

                        updateProfile(context);

                      },
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


