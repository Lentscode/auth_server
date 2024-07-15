part of "../routes.dart";

// Handler per provare l'autorizzazione tramite cookie.
Response echo(Request req) {
  final message = req.params["message"];

  print("Message: $message");

  return Response.ok(message);
}
