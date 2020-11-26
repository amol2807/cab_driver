import 'package:firebase_database/firebase_database.dart';

class Driver {
  String fullName;
  String email;
  String phone;
  String id;
  String carModel;
  String vehicleNumber;
  String carColor;

  Driver(
      {this.fullName,
      this.email,
      this.phone,
      this.id,
      this.carModel,
      this.vehicleNumber,
      this.carColor});

      Driver.fromSnapShot(DataSnapshot snapshot)
      {
         id = snapshot.key;
         phone = snapshot.value['phone'];
         email = snapshot.value['email'];
         fullName = snapshot.value['fullname'];
         carModel = snapshot.value['vehicle_details']['car_model'];
         carColor = snapshot.value['vehicle_details']['car_color'];
         vehicleNumber = snapshot.value['vehicle_details']['vehicle_number'];


      }
}
