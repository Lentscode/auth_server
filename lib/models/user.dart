part of "models.dart";

// Classe che rappresenta un utente.
class User {
  User({
    required this.email,
    required this.id,
    required this.hashedPassword,
    required this.salt,
    this.sessionId,
    this.expirationDate,
  });

  // Email dell'utente.
  final String email;
  // Id dell'utente.
  final ObjectId id;
  // Password codificata.
  final String hashedPassword;
  // Stringa che viene aggiunta alla password prima della codifica.
  final String salt;
  // Stringa che identifica la sessione dell'utente dal momento del login.
  final String? sessionId;
  // Data di scadenza del [sessionId].
  final DateTime? expirationDate;

  // Metodo da utilizzare per mandare i dati dell'utente
  // nella risposta.
  Map<String, dynamic> toJson() => {
        "email": email,
        "_id": id.oid,
      };

  // Costruttore per creare un User da un documento MongoDB.
  User.fromMongo(Map<String, dynamic> json)
      : email = json["email"],
        id = json["_id"],
        hashedPassword = json["password"],
        salt = json["salt"],
        sessionId = json["sessionId"],
        expirationDate = json["expirationTime"];

  // Metodo per creare un User da un altro User.
  User copyWith(
          {String? email,
          ObjectId? id,
          String? hashedPassword,
          String? salt,
          String? sessionId,
          DateTime? expirationDate}) =>
      User(
        email: email ?? this.email,
        id: id ?? this.id,
        hashedPassword: hashedPassword ?? this.hashedPassword,
        salt: salt ?? this.salt,
        sessionId: sessionId,
        expirationDate: expirationDate,
      );

  // Genera una stringa randomica da aggiungere prima della codifica.
  static String generateSalt([int length = 16]) {
    final random = Random.secure();

    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  // Codifica la password.
  static String hashPassword(String password, String salt) {
    final saltedPassword = "$salt$password";

    final bytes = utf8.encode(saltedPassword);

    final digest = sha256.convert(bytes);

    return digest.toString();
  }
}
