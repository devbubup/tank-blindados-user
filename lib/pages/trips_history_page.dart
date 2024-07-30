import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TripsHistoryPage extends StatefulWidget {
  const TripsHistoryPage({super.key});

  @override
  State<TripsHistoryPage> createState() => _TripsHistoryPageState();
}

class _TripsHistoryPageState extends State<TripsHistoryPage> {
  final completedTripRequestsOfCurrentUser = FirebaseDatabase.instance.ref().child("tripRequests");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Viagens',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: completedTripRequestsOfCurrentUser.onValue,
        builder: (BuildContext context, snapshotData) {
          if (snapshotData.hasError) {
            return const Center(
              child: Text(
                "Ocorreu um erro.",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          if (!snapshotData.hasData) {
            return const Center(
              child: Text(
                "Nenhuma corrida foi encontrada para esta conta.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          Map dataTrips = snapshotData.data!.snapshot.value as Map;
          List tripsList = [];
          dataTrips.forEach((key, value) => tripsList.add({"key": key, ...value}));

          return ListView.builder(
            shrinkWrap: true,
            itemCount: tripsList.length,
            itemBuilder: ((context, index) {
              if (tripsList[index]["status"] != null &&
                  tripsList[index]["status"] == "ended" &&
                  tripsList[index]["userID"] == FirebaseAuth.instance.currentUser!.uid) {
                return GestureDetector(
                  onTap: () => showTripDetailsDialog(context, tripsList[index]),
                  child: Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // pickup - fare amount
                          Row(
                            children: [
                              Image.asset('assets/images/initial.png', height: 16, width: 16),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Text(
                                  tripsList[index]["pickUpAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 5),

                              Text(
                                "\$ " + tripsList[index]["fareAmount"].toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // dropoff
                          Row(
                            children: [
                              Image.asset('assets/images/final.png', height: 16, width: 16),

                              const SizedBox(width: 18),

                              Expanded(
                                child: Text(
                                  tripsList[index]["dropOffAddress"].toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }

  void showTripDetailsDialog(BuildContext context, Map tripDetails) async {
    String driverID = tripDetails["driverID"];
    DatabaseReference driverRef = FirebaseDatabase.instance.ref().child("drivers").child(driverID);
    DataSnapshot snapshot = await driverRef.once().then((event) => event.snapshot);

    String driverName = "";
    String driverEmail = "";
    if (snapshot.value != null) {
      Map driverData = snapshot.value as Map;
      driverName = driverData["name"];
      driverEmail = driverData["email"] ?? "Não disponível";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.blue.shade900, width: 2),
          ),
          title: const Text(
            "Detalhes da Viagem",
            style: TextStyle(color: Colors.black),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Partida: ${tripDetails["pickUpAddress"]}",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  "Destino: ${tripDetails["dropOffAddress"]}",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  "Valor: \$${tripDetails["fareAmount"]}",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  "Motorista: $driverName",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  "Email do Motorista: $driverEmail",
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  "Data e Horário: ${tripDetails["publishDateTime"]}",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Fechar",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
