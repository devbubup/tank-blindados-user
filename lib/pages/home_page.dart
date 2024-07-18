import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/methods/manage_drivers_methods.dart';
import 'package:users_app/methods/push_notification_service.dart';
import 'package:users_app/models/direction_details.dart';
import 'package:users_app/models/online_nearby_drivers.dart';
import 'package:users_app/pages/search_destination_page.dart';
import 'package:users_app/pages/profile_page.dart';
import 'package:users_app/pages/destination_search_page.dart';
import 'package:users_app/pages/trips_history_page.dart';
import 'package:users_app/widgets/info_dialog.dart';
import '../appInfo/app_info.dart';
import '../global/trip_var.dart';
import '../widgets/loading_dialog.dart';
import '../widgets/payment_dialog.dart';
import 'about_page.dart';
import 'package:users_app/models/regions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfUser;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  CommonMethods cMethods = CommonMethods();
  double searchContainerHeight = 276;
  double bottomMapPadding = 0;
  double rideDetailsContainerHeight = 0;
  double requestContainerHeight = 0;
  double tripContainerHeight = 0;
  DirectionDetails? tripDirectionDetailsInfo;
  List<LatLng> polylineCoOrdinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  bool isDrawerOpened = true;
  String stateOfApp = "normal";
  bool nearbyOnlineDriversKeysLoaded = false;
  BitmapDescriptor? carIconNearbyDriver;
  DatabaseReference? tripRequestRef;
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  StreamSubscription<DatabaseEvent>? tripStreamSubscription;
  bool requestingDirectionDetailsInfo = false;
  String? selectedServiceType;

  @override
  void initState() {
    super.initState();
    getCurrentLiveLocationOfUser();
    listenToTripStatus();
  }

  @override
  void dispose() {
    tripStreamSubscription?.cancel();
    super.dispose();
  }

  void listenToTripStatus() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").child(user.uid);
      tripStreamSubscription = tripRequestRef!.onValue.listen((event) {
        if (event.snapshot.value != null) {
          Map<String, dynamic> tripData = Map<String, dynamic>.from(event.snapshot.value as Map);
          String tripStatus = tripData["status"];
          String? driverLat = tripData["driverLocation"]?["latitude"];
          String? driverLng = tripData["driverLocation"]?["longitude"];

          print("Trip status updated: $tripStatus");
          print("Driver Location: Lat = $driverLat, Lng = $driverLng");

          setState(() {
            if (tripStatus == "accepted") {
              print("Status: accepted");
              displayTripDetailsContainer();
            } else if (tripStatus == "arrived") {
              print("Status: arrived");
              tripStatusDisplay = "Driver has arrived";
            } else if (tripStatus == "ontrip") {
              if (driverLat != null && driverLng != null) {
                updateFromDriverCurrentLocationToDropOffDestination(LatLng(double.parse(driverLat), double.parse(driverLng)));
              }
            } else if (tripStatus == "completed") {
              print("Status: completed");
              tripStatusDisplay = "Trip completed";
              resetAppNow();
            }
          });
        } else {
          print("Trip request data is null");
        }
      });
    } else {
      print("User is null");
    }
  }

  void updateFromDriverCurrentLocationToPickUp(LatLng driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var userPickUpLocationLatLng = LatLng(
          currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

      var directionDetailsPickUp = await CommonMethods
          .getDirectionDetailsFromAPI(driverCurrentLocationLatLng, userPickUpLocationLatLng);

      if (directionDetailsPickUp == null) {
        print("Failed to get direction details for pick-up");
        requestingDirectionDetailsInfo = false;
        return;
      }

      setState(() {
        print("Updating trip status display for pick-up location");
        tripStatusDisplay = "Motorista está à caminho - ${directionDetailsPickUp.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  void updateFromDriverCurrentLocationToDropOffDestination(LatLng driverCurrentLocationLatLng) async {
    if (!requestingDirectionDetailsInfo) {
      requestingDirectionDetailsInfo = true;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;
      var userDropOffLocationLatLng = LatLng(dropOffLocation!.latitudePosition!,
          dropOffLocation!.longitudePosition!);

      var directionDetailsPickUp = await CommonMethods
          .getDirectionDetailsFromAPI(driverCurrentLocationLatLng, userDropOffLocationLatLng);

      if (directionDetailsPickUp == null) {
        print("Failed to get direction details for drop-off");
        requestingDirectionDetailsInfo = false;
        return;
      }

      setState(() {
        print("Updating trip status display for drop-off location");
        tripStatusDisplay = "Tempo Restante: ${directionDetailsPickUp.durationTextString}";
      });

      requestingDirectionDetailsInfo = false;
    }
  }

  void displayTripDetailsContainer() {
    setState(() {
      print("Displaying trip details container");
      requestContainerHeight = 0;
      tripContainerHeight = 291;
      bottomMapPadding = 201;
    });
  }

  void resetAppNow() {
    setState(() {
      print("Resetting app to initial state");
      polylineCoOrdinates.clear();
      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 0;
      tripContainerHeight = 0;
      searchContainerHeight = 276;
      bottomMapPadding = 300;
      isDrawerOpened = true;

      status = "";
      nameDriver = "";
      photoDriver = "";
      phoneNumberDriver = "";
      carDetailsDriver = "";
      tripStatusDisplay = "Motorista à caminho";
    });
  }

  void makeTripRequest() {
    tripRequestRef = FirebaseDatabase.instance.ref().child("tripRequests").push();

    var pickUpLocation = Provider.of<AppInfo>(context, listen: false).pickUpLocation;
    var dropOffDestinationLocation = Provider.of<AppInfo>(context, listen: false).dropOffLocation;

    Map pickUpCoOrdinatesMap = {
      "latitude": pickUpLocation!.latitudePosition.toString(),
      "longitude": pickUpLocation.longitudePosition.toString(),
    };

    Map dropOffDestinationCoOrdinatesMap = {
      "latitude": dropOffDestinationLocation!.latitudePosition.toString(),
      "longitude": dropOffDestinationLocation.longitudePosition.toString(),
    };

    Map driverCoOrdinates = {
      "latitude": "",
      "longitude": "",
    };

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDateTime": DateTime.now().toString(),
      "userName": userName,
      "userPhone": userPhone,
      "userID": userID,
      "pickUpLatLng": pickUpCoOrdinatesMap,
      "dropOffLatLng": dropOffDestinationCoOrdinatesMap,
      "pickUpAddress": pickUpLocation.placeName,
      "dropOffAddress": dropOffDestinationLocation.placeName,
      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": driverCoOrdinates,
      "driverName": "",
      "driverPhone": "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
      "serviceType": selectedServiceType,
    };

    tripRequestRef!.set(dataMap);

    print("Trip request made with data: $dataMap");

    tripStreamSubscription = tripRequestRef!.onValue.listen((eventSnapshot) async {
      if (eventSnapshot.snapshot.value == null) {
        print("Trip request data is null");
        return;
      }

      var snapshotValue = eventSnapshot.snapshot.value as Map;
      print("Trip request updated with snapshot: $snapshotValue");

      if (snapshotValue["status"] != null) {
        status = snapshotValue["status"];
      }

      if (status == "accepted") {
        displayTripDetailsContainer();
        Geofire.stopListener();
        setState(() {
          markerSet.removeWhere((element) => element.markerId.value.contains("driver"));
        });
      } else if (status == "arrived") {
        setState(() {
          tripStatusDisplay = "O motorista está te aguardando.";
        });
      } else if (status == "ontrip") {
        setState(() {
        });
        if (snapshotValue["driverLocation"] != null) {
          var driverLocation = snapshotValue["driverLocation"];
          updateFromDriverCurrentLocationToDropOffDestination(LatLng(
              double.parse(driverLocation["latitude"].toString()),
              double.parse(driverLocation["longitude"].toString())
          ));
        }
      } else if (status == "ended") {
        print("Trip ended");
        if (snapshotValue["fareAmount"] != null) {
          double fareAmount = double.tryParse(snapshotValue["fareAmount"].toString()) ?? 0.0;
          var responseFromPaymentDialog = await showDialog(
            context: context,
            builder: (BuildContext context) => PaymentDialog(fareAmount: fareAmount.toString()),
          );

          if (responseFromPaymentDialog == "paid") {
            tripRequestRef!.onDisconnect();
            tripRequestRef = null;

            tripStreamSubscription!.cancel();
            tripStreamSubscription = null;

            resetAppNow();
          }
        }
      }
    });
  }


  makeDriverNearbyCarIcon() {
    if (carIconNearbyDriver == null) {
      ImageConfiguration configuration = createLocalImageConfiguration(
          context, size: const Size(0.5, 0.5));
      BitmapDescriptor.fromAssetImage(
          configuration, "assets/images/tracking.png").then((iconImage) {
        carIconNearbyDriver = iconImage;
      });
    }
  }

  getCurrentLiveLocationOfUser() async {
    Position positionOfUser = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfUser = positionOfUser;

    LatLng positionOfUserInLatLng = LatLng(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude);

    CameraPosition cameraPosition = CameraPosition(
        target: positionOfUserInLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    await CommonMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(
        currentPositionOfUser!, context);

    await getUserInfoAndCheckBlockStatus();

    await initializeGeoFireListener();
  }

  getUserInfoAndCheckBlockStatus() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        } else {
          FirebaseAuth.instance.signOut();

          Navigator.push(
              context, MaterialPageRoute(builder: (c) => const LoginScreen()));

          cMethods.displaySnackBar(
              "Você está bloqueado. Entre em contato com o suporte.", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const LoginScreen()));
      }
    });
  }

  displayUserRideDetailsContainer() async {
    if (!Regions.isInPermittedRegions(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude)) {
      showDialog(
        context: context,
        builder: (BuildContext context) =>
            InfoDialog(
              title: "Região Indisponível",
              description: "Os motoristas não trabalham nessa região de partida.",
            ),
      );
      return;
    }

    await retrieveDirectionDetails();

    setState(() {
      searchContainerHeight = 0;
      bottomMapPadding = 240;
      rideDetailsContainerHeight = 320;
      isDrawerOpened = false;
    });
  }

  retrieveDirectionDetails() async {
    var pickUpLocation = Provider
        .of<AppInfo>(context, listen: false)
        .pickUpLocation;
    var dropOffDestinationLocation = Provider
        .of<AppInfo>(context, listen: false)
        .dropOffLocation;

    var pickupGeoGraphicCoOrdinates = LatLng(
        pickUpLocation!.latitudePosition!, pickUpLocation.longitudePosition!);
    var dropOffDestinationGeoGraphicCoOrdinates = LatLng(
        dropOffDestinationLocation!.latitudePosition!,
        dropOffDestinationLocation.longitudePosition!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Obtendo direções..."),
    );

    var detailsFromDirectionAPI = await CommonMethods
        .getDirectionDetailsFromAPI(
        pickupGeoGraphicCoOrdinates, dropOffDestinationGeoGraphicCoOrdinates);
    setState(() {
      tripDirectionDetailsInfo = detailsFromDirectionAPI;
    });

    Navigator.pop(context);

    PolylinePoints pointsPolyline = PolylinePoints();
    List<PointLatLng> latLngPointsFromPickUpToDestination = pointsPolyline
        .decodePolyline(tripDirectionDetailsInfo!.encodedPoints!);

    polylineCoOrdinates.clear();
    if (latLngPointsFromPickUpToDestination.isNotEmpty) {
      latLngPointsFromPickUpToDestination.forEach((PointLatLng latLngPoint) {
        polylineCoOrdinates.add(
            LatLng(latLngPoint.latitude, latLngPoint.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("polylineID"),
        color: Colors.pink,
        points: polylineCoOrdinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude &&
        pickupGeoGraphicCoOrdinates.longitude >
            dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationGeoGraphicCoOrdinates,
        northeast: pickupGeoGraphicCoOrdinates,
      );
    } else if (pickupGeoGraphicCoOrdinates.longitude >
        dropOffDestinationGeoGraphicCoOrdinates.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
      );
    } else if (pickupGeoGraphicCoOrdinates.latitude >
        dropOffDestinationGeoGraphicCoOrdinates.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationGeoGraphicCoOrdinates.latitude,
            pickupGeoGraphicCoOrdinates.longitude),
        northeast: LatLng(pickupGeoGraphicCoOrdinates.latitude,
            dropOffDestinationGeoGraphicCoOrdinates.longitude),
      );
    } else {
      boundsLatLng = LatLngBounds(
        southwest: pickupGeoGraphicCoOrdinates,
        northeast: dropOffDestinationGeoGraphicCoOrdinates,
      );
    }

    controllerGoogleMap!.animateCamera(
        CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    Marker pickUpPointMarker = Marker(
      markerId: const MarkerId("pickUpPointMarkerID"),
      position: pickupGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
          title: pickUpLocation.placeName, snippet: "Pickup Location"),
    );

    Marker dropOffDestinationPointMarker = Marker(
      markerId: const MarkerId("dropOffDestinationPointMarkerID"),
      position: dropOffDestinationGeoGraphicCoOrdinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(title: dropOffDestinationLocation.placeName,
          snippet: "Destination Location"),
    );

    setState(() {
      markerSet.add(pickUpPointMarker);
      markerSet.add(dropOffDestinationPointMarker);
    });

    Circle pickUpPointCircle = Circle(
      circleId: const CircleId('pickupCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: pickupGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    Circle dropOffDestinationPointCircle = Circle(
      circleId: const CircleId('dropOffDestinationCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 4,
      radius: 14,
      center: dropOffDestinationGeoGraphicCoOrdinates,
      fillColor: Colors.pink,
    );

    setState(() {
      circleSet.add(pickUpPointCircle);
      circleSet.add(dropOffDestinationPointCircle);
    });
  }

  cancelRideRequest() {
    tripRequestRef!.remove();

    setState(() {
      stateOfApp = "normal";
    });
  }

  displayRequestContainer() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestContainerHeight = 320;
      bottomMapPadding = 200;
      isDrawerOpened = true;
    });

    makeTripRequest();
  }


  updateAvailableNearbyOnlineDriversOnMap() {
    setState(() {
      markerSet.clear();
    });

    Set<Marker> markersTempSet = Set<Marker>();

    for (OnlineNearbyDrivers eachOnlineNearbyDriver in ManageDriversMethods
        .nearbyOnlineDriversList) {
      LatLng driverCurrentPosition = LatLng(
          eachOnlineNearbyDriver.latDriver!, eachOnlineNearbyDriver.lngDriver!);

      Marker driverMarker = Marker(
        markerId: MarkerId(
            "driver ID = " + eachOnlineNearbyDriver.uidDriver.toString()),
        position: driverCurrentPosition,
        icon: carIconNearbyDriver!,
      );

      markersTempSet.add(driverMarker);
    }

    setState(() {
      markerSet = markersTempSet;
    });
  }

  initializeGeoFireListener() {
    Geofire.initialize("onlineDrivers");
    Geofire.queryAtLocation(
        currentPositionOfUser!.latitude, currentPositionOfUser!.longitude, 22)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent["callBack"];

        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = double.tryParse(driverEvent["latitude"].toString());
            onlineNearbyDrivers.lngDriver = double.tryParse(driverEvent["longitude"].toString());

            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(onlineNearbyDrivers.uidDriver!)
                .child("car_details")
                .child("serviceType")
                .once()
                .then((serviceTypeSnapshot) {
              if (serviceTypeSnapshot.snapshot.value != null) {
                onlineNearbyDrivers.serviceType = serviceTypeSnapshot.snapshot.value.toString();
                print("Driver entered: ${onlineNearbyDrivers.uidDriver}, Latitude: ${onlineNearbyDrivers.latDriver}, Longitude: ${onlineNearbyDrivers.lngDriver}, ServiceType: ${onlineNearbyDrivers.serviceType}");
                ManageDriversMethods.nearbyOnlineDriversList.add(onlineNearbyDrivers);

                if (nearbyOnlineDriversKeysLoaded == true) {
                  updateAvailableNearbyOnlineDriversOnMap();
                }
              } else {
                print("Service type not found for driver: ${onlineNearbyDrivers.uidDriver}");
              }
            });
            break;

          case Geofire.onKeyExited:
            print("Driver exited: ${driverEvent["key"]}");
            ManageDriversMethods.removeDriverFromList(driverEvent["key"]);

            updateAvailableNearbyOnlineDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            OnlineNearbyDrivers onlineNearbyDrivers = OnlineNearbyDrivers();
            onlineNearbyDrivers.uidDriver = driverEvent["key"];
            onlineNearbyDrivers.latDriver = double.tryParse(driverEvent["latitude"].toString());
            onlineNearbyDrivers.lngDriver = double.tryParse(driverEvent["longitude"].toString());

            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(onlineNearbyDrivers.uidDriver!)
                .child("car_details")
                .child("serviceType")
                .once()
                .then((serviceTypeSnapshot) {
              if (serviceTypeSnapshot.snapshot.value != null) {
                onlineNearbyDrivers.serviceType = serviceTypeSnapshot.snapshot.value.toString();
                print("Driver moved: ${onlineNearbyDrivers.uidDriver}, Latitude: ${onlineNearbyDrivers.latDriver}, Longitude: ${onlineNearbyDrivers.lngDriver}, ServiceType: ${onlineNearbyDrivers.serviceType}");
                ManageDriversMethods.updateOnlineNearbyDriversLocation(onlineNearbyDrivers);

                if (nearbyOnlineDriversKeysLoaded == true) {
                  updateAvailableNearbyOnlineDriversOnMap();
                }
              } else {
                print("Service type not found for driver: ${onlineNearbyDrivers.uidDriver}");
              }
            });
            break;

          case Geofire.onGeoQueryReady:
            nearbyOnlineDriversKeysLoaded = true;

            updateAvailableNearbyOnlineDriversOnMap();
            break;
        }
      }
    });
  }

  noDriverAvailable() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InfoDialog(
            title: "Nenhum motorista disponível",
            description: "Nenhum motorista foi encontrado próximo à sua localização. Tente novamente mais tarde."
        )
    );
  }

  searchDriver() {
    OnlineNearbyDrivers? nearestDriver = ManageDriversMethods.getNearestDriver(selectedServiceType!);

    if (nearestDriver != null) {
      print("Nearest driver found: ${nearestDriver.uidDriver}, Latitude: ${nearestDriver.latDriver}, Longitude: ${nearestDriver.lngDriver}, ServiceType: ${nearestDriver.serviceType}");

      sendNotificationToDriver(nearestDriver);
    } else {
      print("No nearest driver found for service type: $selectedServiceType");
      noDriverAvailable();
      resetAppNow();
    }
  }

  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");

    currentDriverRef.set(tripRequestRef!.key);

    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();

        print("Device Token do motorista: $deviceToken");

        PushNotificationService.sendNotificationToSelectedDriver(
            deviceToken,
            context,
            tripRequestRef!.key.toString()
        );
      } else {
        print("Token do dispositivo não encontrado para o motorista");
        return;
      }

      const oneTickPerSec = Duration(seconds: 1);

      var timerCountDown = Timer.periodic(oneTickPerSec, (timer) {
        requestTimeoutDriver = requestTimeoutDriver - 1;

        if (stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;
        }

        currentDriverRef.onValue.listen((dataSnapshot) {
          if (dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 20;
            displayTripDetailsContainer();
          }
        });

        if (requestTimeoutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;

          searchDriver();
        }
      });
    });
  }

  void showServiceInfoDialog(String serviceName) {
    String infoText;
    switch (serviceName) {
      case "Sedan Exec.":
        infoText = "Número de Passageiros: 4 (+ motorista)\nNúmero de Malas: 3\nTipos de Carros: Corolla, Cruze, Sentra";
        break;
      case "Sedan Prime":
        infoText = "Número de Passageiros: 4 (+ motorista)\nNúmero de Malas: 3\nTipos de Carros: BMW Série 3, Mercedes-Benz Classe C";
        break;
      case "SUV Especial":
        infoText = "Número de Passageiros: 6 (+ motorista)\nNúmero de Malas: 4\nTipos de Carros: Compass, Corolla Cross, Taos";
        break;
      case "SUV Prime":
        infoText = "Número de Passageiros: 6 (+ motorista)\nNúmero de Malas: 4\nTipos de Carros: SW4, Commander, Tiguan";
        break;
      case "Mini Van":
        infoText = "Número de Passageiros: 8 (+ motorista)\nNúmero de Malas: 6\nTipos de Carros: Honda Odyssey, Toyota Sienna";
        break;
      case "Van":
        infoText = "Número de Passageiros: 12 (+ motorista)\nNúmero de Malas: 10\nTipos de Carros: Mercedes-Benz Sprinter, Ford Transit";
        break;
      default:
        infoText = "Informações não disponíveis.";
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            serviceName,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            infoText,
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Fechar",
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildServiceTypeCard(
      String serviceName, String serviceImage, DirectionDetails? tripDirectionDetailsInfo) {
    double fare = 0.0;
    if (tripDirectionDetailsInfo != null) {
      fare = cMethods.calculateFareAmount(tripDirectionDetailsInfo, serviceName);
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedServiceType = serviceName;
          stateOfApp = "requesting";
        });

        displayRequestContainer();

        availableNearbyOnlineDriversList = ManageDriversMethods.nearbyOnlineDriversList;

        searchDriver();

      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedServiceType == serviceName ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(serviceImage, height: 60),
                const SizedBox(height: 8),
                Text(serviceName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Fare: \$${fare.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                Text("Time: ${tripDirectionDetailsInfo?.durationTextString ?? ''}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
            Positioned(
              top: -10,
              right: -12,
              child: IconButton(
                icon: Icon(Icons.info, color: Colors.white),
                onPressed: () {
                  showServiceInfoDialog(serviceName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    makeDriverNearbyCarIcon();

    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 255,
        color: Colors.black87,
        child: Drawer(
          backgroundColor: Colors.white10,
          child: ListView(
            children: [
              const Divider(
                height: 1,
                color: Colors.grey,
                thickness: 1,
              ),

              Container(
                color: Colors.black54,
                height: 160,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/avatarman.png",
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (
                                        context) => const ProfilePage()),
                              );
                            },
                            child: const Text(
                              "Profile",
                              style: TextStyle(
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(
                height: 1,
                color: Colors.grey,
                thickness: 1,
              ),

              const SizedBox(
                height: 10,
              ),

              GestureDetector(
                onTap: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutPage()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.info,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "About",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (c) => const LoginScreen()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circleSet,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) {
              controllerGoogleMap = mapController;

              googleMapCompleterController.complete(controllerGoogleMap);

              setState(() {
                bottomMapPadding = 300;
              });

              getCurrentLiveLocationOfUser();
            },
          ),

          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                if (isDrawerOpened == true) {
                  sKey.currentState!.openDrawer();
                } else {
                  resetAppNow();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(
                    isDrawerOpened == true ? Icons.menu : Icons.close,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 250,
              color: Colors.black.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var responseFromSearchPage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => const SearchDestinationPage()));
                      if (responseFromSearchPage == "placeSelected") {
                        displayUserRideDetailsContainer();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              "Qual o destino?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                    const DestinationSearchPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) =>
                                    const TripsHistoryPage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: const EdgeInsets.all(20),
                          ),
                          child: const Icon(
                            Icons.work,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (rideDetailsContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white,
                        blurRadius: 0.0,
                        spreadRadius: 0.0
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          child: SizedBox(
                            height: 340,
                            child: Card(
                              elevation: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1.1,
                                color: Colors.black45,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        "Selecione o Tipo de Serviço",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            buildServiceTypeCard("Sedan Exec.", "assets/images/sedan_executivo.png", tripDirectionDetailsInfo),
                                            buildServiceTypeCard("Sedan Prime", "assets/images/sedan_prime.png", tripDirectionDetailsInfo),
                                            buildServiceTypeCard("SUV Especial", "assets/images/suv_especial.png", tripDirectionDetailsInfo),
                                            buildServiceTypeCard("SUV Prime", "assets/images/suv_prime.png", tripDirectionDetailsInfo),
                                            buildServiceTypeCard("Mini Van", "assets/images/mini_van.png", tripDirectionDetailsInfo),
                                            buildServiceTypeCard("Van", "assets/images/van.png", tripDirectionDetailsInfo),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (requestContainerHeight > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: requestContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width: 200,
                        child: LoadingAnimationWidget.flickr(
                          leftDotColor: Colors.blueAccent,
                          rightDotColor: Colors.red,
                          size: 50,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          resetAppNow();
                          cancelRideRequest();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                width: 1.5, color: Colors.grey),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: tripContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 15.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tripStatusDisplay,
                            style: const TextStyle(fontSize: 19, color: Colors.grey),
                          ),
                        ],
                      ),

                      const SizedBox(height: 19,),

                      const Divider(
                        height: 1,
                        color: Colors.white70,
                        thickness: 1,
                      ),

                      const SizedBox(height: 19,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          ClipOval(
                            child: Image.network(
                              photoDriver == ''
                                  ? "https://firebasestorage.googleapis.com/v0/b/flutter-uber-clone-f49e2.appspot.com/o/avatarman.png?alt=media&token=39a4cc1e-6d96-4c4d-80d3-e8dc99505d73"
                                  : photoDriver,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 8,),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(nameDriver, style: const TextStyle(fontSize: 20, color: Colors.grey,),),

                              Text(carDetailsDriver, style: const TextStyle(fontSize: 14, color: Colors.grey,),),
                            ],
                          ),

                        ],
                      ),

                      const SizedBox(height: 19,),

                      const Divider(
                        height: 1,
                        color: Colors.white70,
                        thickness: 1,
                      ),

                      const SizedBox(height: 19,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          GestureDetector(
                            onTap: ()
                            {
                              launchUrl(Uri.parse("tel://$phoneNumberDriver"));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 11,),

                                const Text("Call", style: TextStyle(color: Colors.grey,),),

                              ],
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),


              )
          ),
        ],
      ),
    );
  }
}