import 'package:users_app/models/online_nearby_drivers.dart';

class ManageDriversMethods {
  static List<OnlineNearbyDrivers> nearbyOnlineDriversList = [];

  static void removeDriverFromList(String key) {
    int index = nearbyOnlineDriversList.indexWhere((driver) => driver.uidDriver == key);
    if (index != -1) {
      nearbyOnlineDriversList.removeAt(index);
    }
  }

  static void updateOnlineNearbyDriversLocation(OnlineNearbyDrivers driver) {
    int index = nearbyOnlineDriversList.indexWhere((d) => d.uidDriver == driver.uidDriver);
    if (index != -1) {
      nearbyOnlineDriversList[index].latDriver = driver.latDriver;
      nearbyOnlineDriversList[index].lngDriver = driver.lngDriver;
    }
  }

  static OnlineNearbyDrivers? getNearestDriver(String selectedServiceType) {
    if (nearbyOnlineDriversList.isNotEmpty) {
      try {
        return nearbyOnlineDriversList.firstWhere((driver) => driver.serviceType == selectedServiceType);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
