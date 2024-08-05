part of "utils.dart";

// Classe ausiliaria per autenticare e autorizzare gli utenti.
class Auth {
  const Auth(this.userCollection);

  // Proprietà per accedere alla collezione "users" di MongoDB.
  final DbCollection userCollection;

  // Crea un sessionId unico.
  String sessionId() => Uuid().v4();

  // Cerca l'utente con l'email data.
  Future<User?> getUserByEmail(String email) async {
    final user = await userCollection.findOne(where.eq("email", email));

    return user != null ? User.fromMongo(user) : null;
  }

  // Registra l'utente tramite email e password.
  Future<User> registerWithEmailAndPassword(String email, String password) async {
    // Il salt viene utilizzato insieme alla password per rendere più
    // sicura la codifica.
    final salt = User.generateSalt();

    final hashedPassword = User.hashPassword(password, salt);

    final user = User(email: email, id: ObjectId(), hashedPassword: hashedPassword, salt: salt);

    await userCollection.insertOne({
      "_id": user.id,
      "email": user.email,
      "password": user.hashedPassword,
      "salt": user.salt,
    });

    return user;
  }

  // Esegue il login tramite email e password.
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    // Cerca l'utente con la data email.
    final user = await getUserByEmail(email);
    if (user == null) {
      return null;
    }

    // Controlla se le password coincidono.
    final hashedPassword = User.hashPassword(password, user.salt);
    if (user.hashedPassword != hashedPassword) {
      return null;
    }

    return user;
  }

  // Crea una sessione per l'utente e la salva nel DB.
  Future<User> createSessionIdOfUser(User user, [DateTime? expirationDate]) async {
    final newSessionId = sessionId();

    final userUpdated = user.copyWith(sessionId: newSessionId);

    await userCollection.updateOne(
      where.id(user.id),
      modify.set("sessionId", newSessionId).set("expirationDate", expirationDate),
    );

    return userUpdated;
  }

  // Cerca l'utente con il [sessionId] dato.
  Future<User?> getUserBySessionID(String? sessionId) async {
    if (sessionId == null) {
      return null;
    }

    final doc = await userCollection.findOne(where.eq("sessionId", sessionId));

    if (doc == null) {
      return null;
    }

    final user = User.fromMongo(doc);

    return user;
  }

  Future<void> deleteUserById(String id) => userCollection.deleteOne(where.id(ObjectId.parse(id)));

  // Metodo per creare un cookie contenente il [sessionId].
  String createCookie(String sessionId, [DateTime? expirationDate]) {
    final cookie = StringBuffer()
      ..write("sessionId=$sessionId; ")
      ..write("path=/protected; ")
      ..write("HttpOnly; ")
      ..write("Secure; ")
      ..write("SameSite=Strict; ");

    // Se il sessionId ha una data di scadenza, settiamo il campo "Expires".
    if (expirationDate != null) {
      cookie.write("Expires=${HttpDate.format(expirationDate)}; ");
    }

    return cookie.toString();
  }
}
