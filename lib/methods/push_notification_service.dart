import 'dart:convert';
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
      "private_key_id": "d9d38f5f98cd4a01215d7228ba6969f9d46fceaf",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCa/lj461HZ84ux\nRMA2DZWDOvspab0VbNogfcLOHVTEEMLKUF8DOAlv2EDIG1VTjmdfqohsneHB30Ku\nUruf8DS02I87TMm4+HZ4H0zwvls019m8zM27dJm42Tbs3oXOEaOsdtocMoTnGkEk\n3B14ss+CwvsabboijbcIMTbut2C/o3S7hG2Iuyzh1UuYqXDT90Qv9US7I1in1Q/U\nhTrfLfadBKNxk3itnOk29P+78EobjjB4NnImrAy8OKcFdXYT8kHnDL/tXEBt6QKZ\nfg6GiLEuzuiB38eO3z/QfGAIFdDhgnCq6kLIRm3Ig9xWkINJN00gowRxE/bTdYyI\nZHiOwTuRAgMBAAECggEAJcPgqPIplPoPKQfP77u6mOmnpg0SGeTWd0E9VJx3+Xf+\nBm6z3+RpBDwEeN2UGlJh5MD4EcMcbXE5XaFh/xP3u7Lin3fT1QKRVy6FQEmZjpQj\nhSm/3TOJey1OAUQtBStuHoktFt7GXEsc4V7SvYSQJFPe/C8NQfsWxGO9d0fuRnMr\nyHGpWMx0qGVl2iILTsjd9wOYa6/Q91cZc62cqF6bOD83AUhMLkjA8Fxsu+WTb4MF\nrjiNtS0FdpiziCrefKg3sR8iK+QeidnmUV7D1r893/HYNW+9DNdIhOO9X9oouAGK\n2M3gdkPv3cmO1uAwyhsItQFVOhyakF6lZzVJlirCmwKBgQDPj9c1Nvz2DssDATCs\n4tWA29ccu6IkGrF4xb+2QPu+kbK7LApoAHvjqX+Q1gHXo97QYEuWu7uoclZ6jNUx\nFE6mnP5Kbo6MTeFxMExulYtSz58gmRe/YtvOk5FjRjZZ1zFDYgnq4kjiKdlc1AOW\nPq8abcHXRH4Js2P7l+56UboIqwKBgQC/KfhdAAqUyakrG/E0Fd+YxEYNRNhuOOyW\n0BIzGxPq94GIdYNVnmOW1Cj8NAYzWY/7g/lybGDRoUbj04bPFgYdbZXRF1z8oNon\n6TBCPJfg/nb3ckbjz6JdjnNGglCz6uIOdVw/PVT8yHIKePy4Kg+YeXhNYejKZLA3\n2KKMUZ+EswKBgAh0xcHHQbsMkzzGGaORgj1Dt5nWEx8Bb2WKOOtF7nuvF+cEPlBK\nZMG7sBTIgz6z0GoQ4kN71oNgVSGdBzp+p02ma73Aj1IsAhlIbHS85vYyuzrqwcrs\nTiQ2Yt/2hlRWrg0eu2S0X1/HcLGVeafvWdbrzc/lXHUst9ASOocFOV0NAoGAFX9Y\nyMyaZAURmyF3TI4xKPLZleBqHmsUYBliEpE2+jN/Q6NDc7tuI6YUPdhz4g5uXLCI\nus9pS+nBGRnOjTdC1MhgErV35YkJP3e/z5MU2V6EbmtRgYj2D2NXn1REUxdU+J9G\nEm6JQiwgdwEIGoXQXys51inujeQo1P7tuK3tLHUCgYEAyMZ0Noabb9Lqq1ne6yWu\nsrvFJcofdn2y7Alvsx/EKZxBaFWWUoS0MS8JJiOV3P73ZK3nbGZz3Pmp1IaxBNhV\nB3RDpKTL9l/d2Km+bXP144vs+ZBbXhSwh1OTeo8gUURvvez/4HWMi4vi1A+b0P8Q\n9x2qiCkmRRAG1XULCH6lvtI=\n-----END PRIVATE KEY-----\n",
      "client_email": "app-blindados@flutter-uber-clone-f49e2.iam.gserviceaccount.com",
      "client_id": "111475864811438034213",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/app-blindados%40flutter-uber-clone-f49e2.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    try {
      var client = await auth.clientViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes);

      // Get Access Token
      auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
          scopes,
          client);

      client.close();

      print("Token de acesso obtido: ${credentials.accessToken.data}");
      return credentials.accessToken.data;
    } catch (e) {
      print("Erro ao obter o token de acesso: $e");
      throw e;
    }
  }

  static sendNotificationToSelectedDriver(
      String deviceToken, BuildContext context, String tripID) async {
    String dropOffDestinationAddress = Provider.of<AppInfo>(context, listen: false).dropOffLocation!.placeName.toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false).pickUpLocation!.placeName.toString();

    try {
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

      if (response.statusCode == 200) {
        print("Notificação enviada com sucesso!");
      } else {
        print("Notificação não enviada: ${response.statusCode}");
        print("Resposta do servidor: ${response.body}");
      }
    } catch (e) {
      print("Erro ao enviar notificação: $e");
    }
  }
}



