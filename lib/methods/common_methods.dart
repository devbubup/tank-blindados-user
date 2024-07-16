import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:http/http.dart' as http;
import 'package:users_app/models/address_model.dart';

import '../models/direction_details.dart';

class CommonMethods
{
  checkConnectivity(BuildContext context) async
  {
    var connectionResult = await Connectivity().checkConnectivity();

    if(connectionResult != ConnectivityResult.mobile && connectionResult != ConnectivityResult.wifi)
    {
      if(!context.mounted) return;
      displaySnackBar("your Internet is not Available. Check your connection. Try Again.", context);
    }
  }

  displaySnackBar(String messageText, BuildContext context)
  {
    var snackBar = SnackBar(content: Text(messageText));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static sendRequestToAPI(String apiUrl) async
  {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));

    try
    {
      if(responseFromAPI.statusCode == 200)
      {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }
      else
      {
        return "error";
      }
    }
    catch(errorMsg)
    {
      return "error";
    }
  }

  ///Reverse GeoCoding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(Position position, BuildContext context) async
  {
    String humanReadableAddress = "";
    String apiGeoCodingUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(apiGeoCodingUrl);

    if(responseFromAPI != "error")
    {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];

      AddressModel model = AddressModel();
      model.humanReadableAddress = humanReadableAddress;
      model.longitudePosition = position.longitude;
      model.latitudePosition = position.latitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(model);
    }

    return humanReadableAddress;
  }

  ///Directions API
  static Future<DirectionDetails?> getDirectionDetailsFromAPI(LatLng source, LatLng destination) async
  {
    String urlDirectionsAPI = "https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$googleMapKey";

    var responseFromDirectionsAPI = await sendRequestToAPI(urlDirectionsAPI);

    if(responseFromDirectionsAPI == "error")
    {
      return null;
    }

    DirectionDetails detailsModel = DirectionDetails();

    detailsModel.distanceTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["text"];
    detailsModel.distanceValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["distance"]["value"];

    detailsModel.durationTextString = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["text"];
    detailsModel.durationValueDigits = responseFromDirectionsAPI["routes"][0]["legs"][0]["duration"]["value"];

    detailsModel.encodedPoints = responseFromDirectionsAPI["routes"][0]["overview_polyline"]["points"];

    return detailsModel;
  }

  double calculateFareAmount(
      DirectionDetails directionDetails, String serviceType) {
    double distancePerKmAmount;
    double durationPerMinuteAmount = 0.3;
    double baseFareAmount;

    switch (serviceType) {
      case 'Sedan Exec.':
        distancePerKmAmount = 0.5;
        baseFareAmount = 3;
        break;
      case 'Sedan Prime':
        distancePerKmAmount = 0.6;
        baseFareAmount = 4;
        break;
      case 'SUV Especial':
        distancePerKmAmount = 0.7;
        baseFareAmount = 5;
        break;
      case 'SUV Prime':
        distancePerKmAmount = 0.8;
        baseFareAmount = 6;
        break;
      case 'Mini Van':
        distancePerKmAmount = 0.9;
        baseFareAmount = 7;
        break;
      case 'Van':
        distancePerKmAmount = 1.0;
        baseFareAmount = 8;
        break;
      default:
        distancePerKmAmount = 0.4;
        baseFareAmount = 2;
    }

    double totalDistanceTravelFareAmount =
        (directionDetails.distanceValueDigits! / 1000) * distancePerKmAmount;
    double totalDurationSpendFareAmount =
        (directionDetails.durationValueDigits! / 60) * durationPerMinuteAmount;

    double overAllTotalFareAmount =
        baseFareAmount + totalDistanceTravelFareAmount + totalDurationSpendFareAmount;

    return overAllTotalFareAmount;
  }
}
