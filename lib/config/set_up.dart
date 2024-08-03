import 'package:auth_server/utils/utils.dart';
import 'package:dotenv/dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

// Variabile globale per accedere al service locator.
final getIt = GetIt.instance;

// Funzione da chiamare per configurare la connessione al database.
Future<void> setUp([bool testing = false]) async {
  // Viene recuperata la chiave per accedere a MongoDB Atlas e viene stabilita
  // la connessione col DB.
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final credentials = testing ? env["MONGO_CREDENTIALS_TEST"] : env["MONGO_CREDENTIALS"];
  final db = await Db.create(credentials ?? "");
  await db.open();

  // Creata l'istanza della classe contenente i metodi per autenticazione
  // ed autorizzazione.
  final auth = Auth(db.collection("users"));

  // Registra l'istanza di [Auth] nel service locator.
  getIt.registerSingleton<Auth>(auth);
}
