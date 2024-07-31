import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveCardPage extends StatefulWidget {
  @override
  _SaveCardPageState createState() => _SaveCardPageState();
}

class _SaveCardPageState extends State<SaveCardPage> {
  bool isLoading = false;

  Future<void> saveCard(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final response = await http.post(
          Uri.parse('https://us-central1-flutter-uber-clone-f49e2.cloudfunctions.net/createSetupIntent'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': user.email,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          if (responseBody['message'] == 'Customer already has a saved card.') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card already saved.')),
            );
          } else {
            final clientSecret = responseBody['clientSecret'];
            await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                setupIntentClientSecret: clientSecret,
                merchantDisplayName: 'Your App Name',
                customerId: responseBody['customer'],
                customerEphemeralKeySecret: responseBody['ephemeralKey'],
                style: ThemeMode.dark,
              ),
            );
            await Stripe.instance.presentPaymentSheet();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card saved successfully.')),
            );
          }
        } else {
          final errorResponse = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save card: ${errorResponse['error']}')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salvar Cartão"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: () => saveCard(context),
          child: const Text("Salvar Cartão"),
        ),
      ),
    );
  }
}
