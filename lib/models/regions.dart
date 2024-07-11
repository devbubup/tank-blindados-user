import 'package:google_maps_flutter/google_maps_flutter.dart';

class Regions {
  static List<LatLng> barraDaTijucaPolygon = [
    LatLng(-22.990, -43.370),
    LatLng(-23.010, -43.240),
    LatLng(-23.030, -43.240),
    LatLng(-23.050, -43.370),
    LatLng(-22.990, -43.370),
  ];

  static List<LatLng> recreioPolygon = [
    LatLng(-23.000, -43.500),
    LatLng(-23.050, -43.470),
    LatLng(-23.070, -43.500),
    LatLng(-23.000, -43.500),
    LatLng(-23.000, -43.500),
  ];

  static List<LatLng> centroPolygon = [
    LatLng(-22.895, -43.225),
    LatLng(-22.895, -43.150),
    LatLng(-22.925, -43.150),
    LatLng(-22.925, -43.225),
    LatLng(-22.895, -43.225),
  ];

  static List<LatLng> galeaoPolygon = [
    LatLng(-22.775, -43.290),
    LatLng(-22.775, -43.200),
    LatLng(-22.825, -43.200),
    LatLng(-22.825, -43.290),
    LatLng(-22.775, -43.290),
  ];

  static List<LatLng> ipanemaPolygon = [
    LatLng(-22.975, -43.215),
    LatLng(-22.975, -43.180),
    LatLng(-23.000, -43.180),
    LatLng(-23.000, -43.215),
    LatLng(-22.975, -43.215),
  ];

  static List<LatLng> botafogoPolygon = [
    LatLng(-22.940, -43.210),
    LatLng(-22.940, -43.160),
    LatLng(-22.955, -43.160),
    LatLng(-22.955, -43.210),
    LatLng(-22.940, -43.210),
  ];

  static List<LatLng> copacabanaPolygon = [
    LatLng(-22.972, -43.195),
    LatLng(-22.972, -43.160),
    LatLng(-22.992, -43.160),
    LatLng(-22.992, -43.195),
    LatLng(-22.972, -43.195),
  ];

  static List<LatLng> lagoaPolygon = [
    LatLng(-22.970, -43.230),
    LatLng(-22.970, -43.185),
    LatLng(-22.990, -43.185),
    LatLng(-22.990, -43.230),
    LatLng(-22.970, -43.230),
  ];

  static List<LatLng> flamengoPolygon = [
    LatLng(-22.930, -43.185),
    LatLng(-22.930, -43.160),
    LatLng(-22.950, -43.160),
    LatLng(-22.950, -43.185),
    LatLng(-22.930, -43.185),
  ];

  static List<LatLng> gaveaPolygon = [
    LatLng(-22.970, -43.245),
    LatLng(-22.970, -43.225),
    LatLng(-22.990, -43.225),
    LatLng(-22.990, -43.245),
    LatLng(-22.970, -43.245),
  ];

  static List<LatLng> humaitaPolygon = [
    LatLng(-22.950, -43.195),
    LatLng(-22.950, -43.175),
    LatLng(-22.965, -43.175),
    LatLng(-22.965, -43.195),
    LatLng(-22.950, -43.195),
  ];

  static List<LatLng> jardimBotanicoPolygon = [
    LatLng(-22.965, -43.235),
    LatLng(-22.965, -43.215),
    LatLng(-22.980, -43.215),
    LatLng(-22.980, -43.235),
    LatLng(-22.965, -43.235),
  ];

  static List<LatLng> laranjeirasPolygon = [
    LatLng(-22.935, -43.195),
    LatLng(-22.935, -43.170),
    LatLng(-22.950, -43.170),
    LatLng(-22.950, -43.195),
    LatLng(-22.935, -43.195),
  ];

  static List<LatLng> lemePolygon = [
    LatLng(-22.970, -43.190),
    LatLng(-22.970, -43.160),
    LatLng(-22.985, -43.160),
    LatLng(-22.985, -43.190),
    LatLng(-22.970, -43.190),
  ];

  static List<LatLng> saoConradoPolygon = [
    LatLng(-22.990, -43.275),
    LatLng(-22.990, -43.240),
    LatLng(-23.010, -43.240),
    LatLng(-23.010, -43.275),
    LatLng(-22.990, -43.275),
  ];

  static List<LatLng> leblonPolygon = [
    LatLng(-22.985, -43.235),
    LatLng(-22.985, -43.200),
    LatLng(-23.000, -43.200),
    LatLng(-23.000, -43.235),
    LatLng(-22.985, -43.235),
  ];

  static bool isInPermittedRegions(double latitude, double longitude) {
    return isInPolygon(barraDaTijucaPolygon, latitude, longitude) ||
        isInPolygon(recreioPolygon, latitude, longitude) ||
        isInPolygon(centroPolygon, latitude, longitude) ||
        isInPolygon(galeaoPolygon, latitude, longitude) ||
        isInPolygon(ipanemaPolygon, latitude, longitude) ||
        isInPolygon(botafogoPolygon, latitude, longitude) ||
        isInPolygon(copacabanaPolygon, latitude, longitude) ||
        isInPolygon(lagoaPolygon, latitude, longitude) ||
        isInPolygon(flamengoPolygon, latitude, longitude) ||
        isInPolygon(gaveaPolygon, latitude, longitude) ||
        isInPolygon(humaitaPolygon, latitude, longitude) ||
        isInPolygon(jardimBotanicoPolygon, latitude, longitude) ||
        isInPolygon(laranjeirasPolygon, latitude, longitude) ||
        isInPolygon(lemePolygon, latitude, longitude) ||
        isInPolygon(saoConradoPolygon, latitude, longitude) ||
        isInPolygon(leblonPolygon, latitude, longitude);
  }

  static bool isInPolygon(List<LatLng> polygon, double latitude, double longitude) {
    bool isInPolygon = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].longitude > longitude) != (polygon[j].longitude > longitude) &&
          (latitude < (polygon[j].latitude - polygon[i].latitude) * (longitude - polygon[i].longitude) / (polygon[j].longitude - polygon[i].longitude) + polygon[i].latitude)) {
        isInPolygon = !isInPolygon;
      }
      j = i;
    }

    return isInPolygon;
  }
}
