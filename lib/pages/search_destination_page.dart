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
  final String? initialSearchText;
  final LatLng? predefinedDestinationLatLng;

  const SearchDestinationPage({super.key, this.initialSearchText, this.predefinedDestinationLatLng});

  @override
  State<SearchDestinationPage> createState() => _SearchDestinationPageState();
}

class _SearchDestinationPageState extends State<SearchDestinationPage> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController = TextEditingController();
  List<PredictionModel> dropOffPredictionsPlacesList = [];
  List<Map<String, dynamic>> suggestionList = [
    {"name": "Copacabana", "icon": Icons.beach_access, "description": "Famosa praia no Rio de Janeiro"},
    {"name": "Maracanã", "icon": Icons.sports_soccer, "description": "Estádio de futebol famoso"},
    {"name": "Barra Shopping", "icon": Icons.shop, "description": "O maior shopping do Rio de Janeiro"},
    {"name": "Parque Lage", "icon": Icons.park, "description": "Parque com trilhas e uma mansão histórica"},
    {"name": "Museu do Amanhã", "icon": Icons.museum, "description": "Museu de ciências futurístico"},
    {"name": "AquaRio", "icon": Icons.pool, "description": "O maior aquário marinho da América do Sul"},
  ];

  @override
  void initState() {
    super.initState();
    String userAddress = Provider.of<MyAppInfo>(context, listen: false).pickUpLocation?.humanReadableAddress ?? "";
    pickUpTextEditingController.text = userAddress;

    if (widget.initialSearchText != null) {
      destinationTextEditingController.text = widget.initialSearchText!;
      searchLocation(widget.initialSearchText!); // Perform search with initial search text
    }

    if (widget.predefinedDestinationLatLng != null) {
      // Handle predefined destination logic if necessary
    }
  }

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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: Container(
                height: 230,
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
                              'Selecione um Destino',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
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

            if (suggestionList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sugestões do Guardião:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestionList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              destinationTextEditingController.text = suggestionList[index]['name'];
                              searchLocation(suggestionList[index]['name']);
                            },
                            child: Container(
                              width: 260,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 0.5,
                                    offset: Offset(0.7, 0.7),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    suggestionList[index]['icon'],
                                    color: Colors.black54,
                                    size: 50,
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          suggestionList[index]['name'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          suggestionList[index]['description'],
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                  ],
                ),
              ),

            // Exibindo resultados da pesquisa de local
            (dropOffPredictionsPlacesList.isNotEmpty)
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
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 2),
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
