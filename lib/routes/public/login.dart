part of "../routes.dart";

// Handler per eseguire il login.
Future<Response> login(Request req) async {
  // Accediamo ai dati mandati tramite la richiesta.
  final data = await RequestUtils.getPayload(req);
  final email = data["email"];
  final password = data["password"];

  // Controlliamo che non siano nulli.
  if (email == null || password == null) {
    return Response.badRequest(body: "Email or password missing");
  }

  // Accediamo all'oggetto [Auth].
  final auth = getIt.get<Auth>();

  // Cerchiamo un utente con la stessa email e la stessa password.
  final user = await auth.loginWithEmailAndPassword(email, password);

  // Se non viene trovato l'utente, rifiutiamo la richiesta.
  if (user == null) {
    return Response.unauthorized("Invalid credentials");
  }

  // Viene creato un sessionId per l'utente.
  final userWithSessionId = await auth.createSessionIdOfUser(user);

  // Creiamo un cookie per immagazzinare il sessionId.
  final cookie = auth.createCookie(userWithSessionId.sessionId!, userWithSessionId.expirationDate);

  return Response.ok(
    jsonEncode(userWithSessionId.toJson()),
    headers: {
      "Content-Type": "application/json",
      "Set-Cookie": cookie,
    },
  );
}
