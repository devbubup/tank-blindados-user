import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = "";
String userPhone = "";
String userID = FirebaseAuth.instance.currentUser!.uid;

String googleMapKey = "AIzaSyBigH1cQcYYV1cf0wuj93ShJB59t1lXuMo";

const CameraPosition googlePlexInitialPosition = CameraPosition(
    target: LatLng(-22.91, -43.2),
    zoom: 14.4766
);