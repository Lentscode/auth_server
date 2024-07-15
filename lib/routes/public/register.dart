part of "../routes.dart";

// Handler per eseguire la registrazione.
Future<Response> register(Request req) async {
  // Accediamo ai dati mandati tramite la richiesta.
  final data = await RequestUtils.getPayload(req);
  final email = data["email"];
  final password = data["password"];

  // Accediamo all'oggetto [Auth].
  final auth = getIt.get<Auth>();

  // Controlliamo che non siano nulli.
  if (email == null || password == null) {
    return Response.badRequest(body: "Email or password missing");
  }

  // Controlliamo che l'email non sia già stata usata.
  final userExists = await auth.getUserByEmail(email) != null;

  // Se sì, rifiutiamo la richiesta.
  if (userExists) {
    return Response.forbidden("Invalid credentials");
  }

  // Registriamo l'utente nel DB.
  final user = await auth.registerWithEmailAndPassword(email, password);

  return Response.ok(
    jsonEncode(user.toJson()),
    headers: {"Content-Type": "application/json"},
  );
}
