part of "../routes.dart";

// Handler per provare l'autorizzazione tramite cookie.
Response echo(Request req) {
  final message = req.params["message"];

  final id = req.context["id"];

  print("Message: $message; Id: $id");

  return Response.ok(message);
}
