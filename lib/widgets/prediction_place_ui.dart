import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/info_dialog.dart';
import 'package:users_app/widgets/loading_dialog.dart';
import 'package:users_app/models/regions.dart'; // Importar o arquivo regions

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;
  final bool Function(double, double) isInPermittedRegionCallback;

  PredictionPlaceUI({super.key, this.predictedPlaceData, required this.isInPermittedRegionCallback});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  fetchClickedPlaceDetails(String placeID) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(messageText: "Planejando a corrida..."),
    );

    String urlPlaceDetailsAPI = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapKey";

    var responseFromPlaceDetailsAPI = await CommonMethods.sendRequestToAPI(urlPlaceDetailsAPI);

    Navigator.pop(context);

    if (responseFromPlaceDetailsAPI == "error") {
      return;
    }

    if (responseFromPlaceDetailsAPI["status"] == "OK") {
      double latitude = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lat"];
      double longitude = responseFromPlaceDetailsAPI["result"]["geometry"]["location"]["lng"];

      if (!widget.isInPermittedRegionCallback(latitude, longitude)) {
        showDialog(
          context: context,
          builder: (BuildContext context) => InfoDialog(
            title: "Região Indisponível",
            description: "Os motoristas da empresa não trabalham no endereço selecionado como destino.",
          ),
        );
        return;
      }

      AddressModel dropOffLocation = AddressModel(
        placeName: responseFromPlaceDetailsAPI["result"]["name"],
        latitudePosition: latitude,
        longitudePosition: longitude,
        placeID: placeID,
      );

      Provider.of<MyAppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.predictedPlaceData!.main_text.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.predictedPlaceData!.secondary_text.toString(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
