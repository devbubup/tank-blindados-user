import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../methods/common_methods.dart';

class PaymentDialog extends StatefulWidget {
  final String fareAmount;
  final String clientSecret;

  PaymentDialog({super.key, required this.fareAmount, required this.clientSecret});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  CommonMethods cMethods = CommonMethods();
  bool isLoading = false;

  Future<void> initPayment({
    required String email,
    required double amount,
    required BuildContext context,
  }) async {
    setState(() {
      isLoading = true;
    });

    try {
      log('Initiating payment...');
      final response = await http.post(
        Uri.parse('https://us-central1-flutter-uber-clone-f49e2.cloudfunctions.net/stripePaymentIntentRequest'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'amount': (amount * 100).toInt().toString(),
        }),
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log('JSON response: $jsonResponse');

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: widget.clientSecret,
            merchantDisplayName: 'Guard. Blindados',
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            style: ThemeMode.dark,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment is successful'),
            ),
          );
          Navigator.pop(context, "paid");
        }
      } else {
        log('Error response: ${response.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initiate payment.'),
            ),
          );
        }
      }
    } catch (error) {
      log('Error: $error');
      if (mounted) {
        if (error is StripeException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${error.error.localizedMessage}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: $error'),
            ),
          );
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Colors.black54,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 21),
            const Text(
              "PAGAMENTO",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 21),
            const Divider(
              height: 1.5,
              color: Colors.white70,
              thickness: 1.0,
            ),
            const SizedBox(height: 16),
            Text(
              "\$" + widget.fareAmount,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "O valor da corrida foi de \$ ${widget.fareAmount}. Antes de sair, efetue o pagamento.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, "paid");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Dinheiro"),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await initPayment(
                      email: 'email@test.com', // Use o email do usuário
                      amount: double.parse(widget.fareAmount),
                      context: context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(" Cartão "),
                ),
              ],
            ),
            const SizedBox(height: 41),
          ],
        ),
      ),
    );
  }
}
