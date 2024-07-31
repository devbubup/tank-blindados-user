import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class SaveCardView extends StatefulWidget {
  final Function onCardSaved;

  const SaveCardView({required this.onCardSaved, Key? key}) : super(key: key);

  @override
  _SaveCardViewState createState() => _SaveCardViewState();
}

class _SaveCardViewState extends State<SaveCardView> {
  bool isLoading = false;
  String? clientSecret;

  @override
  void initState() {
    super.initState();
    createSetupIntent();
  }

  Future<void> createSetupIntent() async {
    setState(() {
      isLoading = true;
    });

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
        setState(() {
          clientSecret = responseBody['clientSecret'];
          isLoading = false;
        });
      } else {
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create setup intent: ${errorResponse['error']}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> saveCard() async {
    if (clientSecret == null) {
      return;
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret!,
          merchantDisplayName: 'Your App Name',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Card saved successfully!')),
      );
      widget.onCardSaved();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: saveCard,
            child: Text('Salvar Cartão'),
          ),
          TextButton(
            onPressed: () {
              widget.onCardSaved();
            },
            child: Text('Pular'),
          ),
        ],
      ),
    );
  }
}
