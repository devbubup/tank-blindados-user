import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/appInfo/app_info.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/models/address_model.dart';
import 'package:users_app/models/prediction_model.dart';
import 'package:users_app/widgets/info_dialog.dart';
import 'package:users_app/widgets/loading_dialog.dart';

class PredictionPlaceUI extends StatefulWidget {
  final PredictionModel? predictedPlaceData;
  final bool Function(double, double) isInZonaOesteCallback;

  PredictionPlaceUI({super.key, this.predictedPlaceData, required this.isInZonaOesteCallback});

  @override
  State<PredictionPlaceUI> createState() => _PredictionPlaceUIState();
}

class _PredictionPlaceUIState extends State<PredictionPlaceUI> {
  ///Place Details - Places API
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

      if (widget.isInZonaOesteCallback(latitude, longitude)) {
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

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocation(dropOffLocation);
      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        fetchClickedPlaceDetails(widget.predictedPlaceData!.place_id.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],  // Cinza escuro para combinar com PredictionPlaceUIForSchedule
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),  // Bordas ligeiramente arredondadas
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.predictedPlaceData!.main_text.toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,  // Texto branco para contraste
                ),
              ),
            ),
            const SizedBox(height: 3,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.predictedPlaceData!.secondary_text.toString(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,  // Texto branco com opacidade
                ),
              ),
            ),
            const SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }
}
