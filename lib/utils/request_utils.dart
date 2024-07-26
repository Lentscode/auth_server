import 'dart:convert';

import 'package:shelf/shelf.dart';

// Classe ausiliaria per ottenere dati dalla [Request].
class RequestUtils {
  // Recupera dati dal corpo della richiesta.
  static Future<Map<String, dynamic>> getPayload(Request req) async {
    final payload = await req.readAsString();
    final data = jsonDecode(payload);

    return data;
  }

  // Recupera il [sessionId] dai cookies.
  static String? getSessionId(Request req) {
    final cookies = req.headers["Cookie"];

    String? sessionId;

    if (cookies == null) {
      return null;
    }

    final cookieList = cookies.split(";");

    for (var cookie in cookieList) {
      final keyValue = cookie.split("=");

      if (keyValue.length == 2 && keyValue[0].trim() == "sessionId") {
        sessionId = keyValue[1].trim();
        break;
      }
    }

    return sessionId;
  }

  static Future<(String? email, String? password)> getEmailAndPasswordFromRequest(Request req) async {
    final payload = await getPayload(req);

    return (payload["email"] as String?, payload["password"] as String?);
  }
}
