import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final String DATABASE_NAME = "mode.db";
  static final String TABLE_LOG = "log";
  static final String TABLE_VISIT_LOG = "visit_log";
  static final int DATABASE_VERSION = 1;
  static DatabaseHelper? _instance;

  DatabaseHelper._();

  static Future<DatabaseHelper?> getInstance() async {
    _instance ??= DatabaseHelper._();
    _database ??= await initDatabase();
    return _instance;
  }

  static Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), DATABASE_NAME);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if(DATABASE_VERSION > 1 && oldVersion == DATABASE_VERSION - 1 && newVersion == DATABASE_VERSION) {
          await db.execute("DROP TABLE IF EXISTS $TABLE_LOG");
          createTable(db);
        }
      }
    );
  }

  static Future<void> createTable(Database db) async {
    await db.execute("CREATE TABLE $TABLE_LOG (logid INTEGER PRIMARY KEY AUTOINCREMENT, time INTEGER, log TEXT)");
  }

  void insertLog(String log) {
    _database?.insert(TABLE_LOG, {'time': DateTime.now().microsecondsSinceEpoch, 'log': log});
  }

  Future<List<Map>> queryLog() async {
    Future<List<Map>> logList = await _database!!.rawQuery('SELECT * FROM $TABLE_LOG ORDER BY time DESC');
    return logList;
  }
}