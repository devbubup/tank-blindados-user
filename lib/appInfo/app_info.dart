import 'package:flutter/cupertino.dart';
import 'package:users_app/models/address_model.dart';

class MyAppInfo extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }

  // Novo método para atualizar apenas o endereço legível do local de coleta
  void updatePickUpLocationAddress(String address) {
    if (pickUpLocation != null) {
      pickUpLocation!.humanReadableAddress = address;
      notifyListeners();
    }
  }
}
