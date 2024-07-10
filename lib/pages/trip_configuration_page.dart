import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../global/global_var.dart';

class TripSettingsPage extends StatefulWidget {
  final String pickUpPlaceName;
  final String destinationPlaceName;

  const TripSettingsPage({
    Key? key,
    required this.pickUpPlaceName,
    required this.destinationPlaceName,
  }) : super(key: key);

  @override
  _TripSettingsPageState createState() => _TripSettingsPageState();
}

class _TripSettingsPageState extends State<TripSettingsPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedServiceType;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  void _confirmBooking() {
    if (selectedDate != null && selectedTime != null && selectedServiceType != null) {
      final DateTime finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      DatabaseReference bookingRef = FirebaseDatabase.instance.ref().child("agendamentosPendentes").push();

      Map<String, dynamic> bookingData = {
        "userID": userID,
        "userName": userName,
        "userPhone": userPhone,
        "userEmail": FirebaseAuth.instance.currentUser!.email,
        "pickUpPlaceName": widget.pickUpPlaceName,
        "destinationPlaceName": widget.destinationPlaceName,
        "scheduledDateTime": finalDateTime.toIso8601String(),
        "serviceType": selectedServiceType,
        "status": "Agendado",
      };

      bookingRef.set(bookingData);

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Agendamento Confirmado"),
          content: const Text("Sua viagem foi agendada com sucesso."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retorna à tela inicial
              },
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Informações Incompletas"),
          content: const Text("Por favor, selecione a data, hora e tipo de serviço."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações da Viagem"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.location_pin, color: Colors.white, size: 30),
                  title: Text(
                    "Partida: ${widget.pickUpPlaceName}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.flag, color: Colors.white, size: 30),
                  title: Text(
                    "Destino: ${widget.destinationPlaceName}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? 'Selecione a Data'
                            : 'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedTime == null
                            ? 'Selecione o Horário'
                            : 'Horário: ${selectedTime!.format(context)}',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.access_time, color: Colors.white, size: 30),
                      onPressed: () => _selectTime(context),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                DropdownButton<String>(
                  hint: const Text("Selecione o Tipo de Serviço", style: TextStyle(color: Colors.white, fontSize: 20)),
                  dropdownColor: Colors.black87,
                  value: selectedServiceType,
                  items: <String>['Sedan Executivo', 'Sedan Prime', 'SUV Especial', 'SUV Prime', 'Mini Van', 'Van']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 20)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedServiceType = newValue;
                    });
                  },
                ),
                const SizedBox(height: 220),
                Center(
                  child: ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                    child: const Text("Confirmar Agendamento", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
