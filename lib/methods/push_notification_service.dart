import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import '../appInfo/app_info.dart';
import '../global/global_var.dart';

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "flutter-uber-clone-f49e2",
      "private_key_id": "38df837174b0804a45c0b9f14f5889fc6e1cecdc",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCodEFNZ87Kmqxq\ncrnZhX7XSE2xnOvhXq+XzhZjmTDUiwJ9vWDv6T4tHUpr+qweJBs4O9EZ0D14aXSw\nPiNdq8TTdYxVhEyefW6C0yIIaMt0AgUQypPkIivEBh5eTMGsZq4VfqpY4vPBY5g1\nVmhutmhAvgeqTGxQjlcTmMHRP9fPQ/0VmVGYn3eUPGsEoGKAo3ofAmbFwzvLXAdC\nwFPcNKULgooQrkGZ5CovoMnp9PI6jUWrVNlWRLm0R+B3hKW5boonuZBmTYTvU2pb\nNUqj/EBDSjsL7UBYzkNyUTq8i1N/60HYbMLIW4r3Z9iW45JtpXzdbI8l8d7xTt/T\nRtq1XH/DAgMBAAECggEADpxexExPsbUEEAuOtnY6D97T66bfsrbYEMOtn3U8Y1hX\nSU6xZ2hZ8zx00F7NVPlEFHbju73FxyQ7xxmXTwWaAc6n8ww8P7buFzzMLoyLBlnd\nKfKtgdO7lg9Yd6ISs6sISGb/IXc14JKMiNEg0mbR2LkNcyZDyCJAcpEE++ryA1EP\nRLYHkF7wroW/YSEsJKgTp+4WIysgPCI/XYGELTKF84yhHcIG/jEwjCshKytf8r3q\nfYh3vv+rGYamdtnvQZ5PA08JqrDe5t19D70KwLLeMKMiAVpljfYeBFqZh7j8sWkj\nyBmE/nRXPGnm5hHLI4tnqTz8H0YqsVb+asH3pPdwmQKBgQDZlbwxeomn8mT+WOpg\n/uSriKGCw3zl0FnOK+Ck8VEnAohAfyr3FyuSmejXO2VFC0Xs6KH5Pqj5k+9HEN3M\nJJrgUuiK91unmCdFB9UW2Ik9GVSDqqggaOfo3hSjD4olnsurpWbzLXyc78d2PCol\nADbCyiLRa2i+Zysn+G/78lep7wKBgQDGMfAeSHTZjKAMsH1tpWdsRfxWTIcBJqB8\nvp+YozhCLcqBEL+PfvmPlRKTTAr63dwPc54GrqAssxW4mnhl29pvd3/eCf6ofr3X\nPOnD79NRygS6vFwgmLWzafrntJPQHIS6o0EHd0MiTDXQlsVxVJQB6K9ThZ7Ke587\nqBTWMWIrbQKBgHA13lYOAcvRH/Bj3oujKD6mOdT8B/9k0cuXqUSnBtj9X1MTwg6n\nrlrucLv+750J0Uf6OP4XKIF9n1qhAiFzh0PEvhRcuLHXr/jTrzsW9L/DvmggrI/6\nSg836KCnNPFt0U91/3/Np4QvzEfXg0yNrbALGqWxpNT8067LWsUuF7OVAoGBALeU\nSfXC53ka6KTYVVXaf5GqwbCt8d7/CGiDqRCZHuMtxwUFnmosEr0MN8h4BzOXjN5D\nGXzXA0ZkGxqC+kJfAlV9OtNQLrGjs/RKV71Fx1da6EaPckY/LQ6ie+VjPgbmY4r8\n7J8duPFr5ezvurLexLl/7eZPPmYPW87GQYak92mBAoGBAJ6gqUsLd4oj6VMWOdlP\nUwGsA14NCskeiGm4r74PPkcSqbedvk4ijDvdI05BTrEyDlvNbOIXviT1pFfrXiGe\nYNDljwAvowlS6USPm53DNZ68SAVgVCpbJMy8pQ3C89bRNLUyDT1aBobVMPar9id1\nGQ9bR4y71mAqsyfvECSI1jOO\n-----END PRIVATE KEY-----\n",
      "client_email": "ios-tank@flutter-uber-clone-f49e2.iam.gserviceaccount.com",
      "client_id": "112386953827187432011",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/ios-tank%40flutter-uber-clone-f49e2.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes
    );

    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken,
      BuildContext context, String tripID) async {
    String dropOffDestinationAddress = Provider
        .of<AppInfo>(context, listen: false)
        .dropOffLocation!
        .placeName
        .toString();
    String pickUpAddress = Provider
        .of<AppInfo>(context, listen: false)
        .pickUpLocation!
        .placeName
        .toString();

    final String serverAccessTokenKey = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/flutter-uber-clone-f49e2/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {
          'title': "NOVA PROPOSTA DE CORRIDA de $userName",
          'body': "Busca: $pickUpAddress \nDestino: $dropOffDestinationAddress"
        },
        'data': {
          'tripID': tripID,
        }
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200)
    {
      print("Notificação Enviada!");
    }
    else
    {
      print("Notificação Falhou: ${response.statusCode}");
    }
  }
}
