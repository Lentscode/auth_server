part of "middlewares.dart";

// Middleware per controllare che l'utente sia autorizzato ad accedere
// alle routes protette, attraverso il sessionId.
Middleware checkSessionId() {
  return (Handler innerHandler) {
    return (Request req) async {
      // Ottiene il [sessionId] dal cookie.
      final sessionId = RequestUtils.getSessionId(req);

      // Accediamo all'oggetto [Auth].
      final auth = getIt.get<Auth>();

      // Ottiene l'utente dal [sessionId].
      final user = await auth.getUserBySessionID(sessionId);

      // Se [user] è nullo, allora rifiutiamo la richiesta.
      if (user == null) {
        return Response.unauthorized("SessionID not valid");
      }

      // Se l'utente è autorizzato, aggiorniamo la richiesta e la
      // passiamo all'handler.
      print("User with sessionId: $sessionId authorized");
      final updatedRequest = req.change(context: {'id': user.id});
      return await innerHandler(updatedRequest);
    };
  };
}
