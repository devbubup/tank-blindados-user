import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/prediction_place_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../appInfo/app_info.dart';
import '../widgets/info_dialog.dart';
import 'package:users_app/models/regions.dart'; // Importar o arquivo regions

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<PredictionModel> dropOffPredictionsPlacesList = [];

  searchLocation(String locationName) async {
    if (locationName.length > 1) {
      String apiPlacesUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:br";

      var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(apiPlacesUrl);

      if (responseFromPlacesAPI == "error") {
        return;
      }

      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionResultInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionResultInJson as List).map((eachPlacePrediction) => PredictionModel.fromJson(eachPlacePrediction)).toList();

        setState(() {
          dropOffPredictionsPlacesList = predictionsList;
        });
      }
    }
  }

  bool isInPermittedRegion(double latitude, double longitude) {
    return Regions.isInPermittedRegions(latitude, longitude);
  }

  void checkPickUpLocation() async {
    String pickUpPlaceID = pickUpTextEditingController.text;

    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$pickUpPlaceID&key=$googleMapKey";

    var responseFromPlaceDetailsAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    if (responseFromPlaceDetailsAPI == "error") {
      return;
    }

    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      double latitude = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      double longitude = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];

      if (!isInPermittedRegion(latitude, longitude)) {
        showDialog(
          context: context,
          builder: (BuildContext context) => InfoDialog(
            title: "Região Indisponível",
            description: "Os motoristas da empresa não trabalham no endereço selecionado como partida.",
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.humanReadableAddress ?? "";
    pickUpTextEditingController.text = userAddress;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6,),

                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back, color: Colors.white,),
                          ),
                          const Center(
                            child: Text(
                              "Selecione um destino",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18,),

                      Row(
                        children: [
                          Image.asset(
                            "assets/images/initial.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18,),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  onChanged: (inputText) {
                                    checkPickUpLocation();
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Endereço de Partida",
                                      fillColor: Colors.white12,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11,),

                      Row(
                        children: [
                          Image.asset(
                            "assets/images/final.png",
                            height: 16,
                            width: 16,
                          ),
                          const SizedBox(width: 18,),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  onChanged: (inputText) {
                                    searchLocation(inputText);
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Endereço do Destino",
                                      fillColor: Colors.white12,
                                      filled: true,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            (dropOffPredictionsPlacesList.length > 0)
                ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 3,
                    child: PredictionPlaceUI(
                      predictedPlaceData: dropOffPredictionsPlacesList[index],
                      isInPermittedRegionCallback: isInPermittedRegion,
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 2,),
                itemCount: dropOffPredictionsPlacesList.length,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
