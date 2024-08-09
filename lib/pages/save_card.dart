import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:firebase_auth/firebase_auth.dart';

class SaveCardPage extends StatefulWidget {
  @override
  _SaveCardPageState createState() => _SaveCardPageState();
}

class _SaveCardPageState extends State<SaveCardPage> {
  bool isLoading = false;
  List<dynamic> savedCards = [];

  Future<void> saveCard(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

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
            await stripe.Stripe.instance.initPaymentSheet(
              paymentSheetParameters: stripe.SetupPaymentSheetParameters(
                setupIntentClientSecret: clientSecret,
                merchantDisplayName: 'Your App Name',
                customerId: responseBody['customer'],
                customerEphemeralKeySecret: responseBody['ephemeralKey'],
                style: ThemeMode.dark,
              ),
            );
            await stripe.Stripe.instance.presentPaymentSheet();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cartão salvo com sucesso.')),
            );
            fetchSavedCards();
          }
        } else {
          final errorResponse = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Salvamento do Cartão Falhou: ${errorResponse['error']}')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Um Erro Ocorreu: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSavedCards() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final response = await http.post(
          Uri.parse('https://us-central1-flutter-uber-clone-f49e2.cloudfunctions.net/listPaymentMethods'),
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
            savedCards = responseBody['data'];
          });
        } else {
          final errorResponse = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load saved cards: ${errorResponse['error']}')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> removeCard(String paymentMethodId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://us-central1-flutter-uber-clone-f49e2.cloudfunctions.net/removePaymentMethod'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'paymentMethodId': paymentMethodId,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cartão removido com sucesso.')),
        );
        fetchSavedCards();  // Refresh saved cards after removing one
      } else {
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${errorResponse['error']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSavedCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerenciar Cartões"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Salvar Cartão",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Aqui você pode salvar seus cartões de crédito para facilitar pagamentos futuros. Apenas um cartão pode ser salvo por vez.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Divider(height: 32, thickness: 2),
            if (isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ] else ...[
              const Text(
                "Caso não tenha um cartão salvo, clique aqui para salvar um novo cartão.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => saveCard(context),
                  child: const Text("Salvar Novo Cartão"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 32, thickness: 2),
              const Text(
                "Cartões Salvos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              savedCards.isNotEmpty
                  ? Expanded(
                child: ListView.builder(
                  itemCount: savedCards.length,
                  itemBuilder: (context, index) {
                    final card = savedCards[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.credit_card, color: Colors.blueAccent),
                        title: Text('**** **** **** ${card['card']['last4']}'),
                        subtitle: Text('${card['card']['brand'].toUpperCase()}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => removeCard(card['id']),
                        ),
                      ),
                    );
                  },
                ),
              )
                  : const Text('Nenhum cartão salvo encontrado', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
