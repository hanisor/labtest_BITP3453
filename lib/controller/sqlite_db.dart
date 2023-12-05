import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDB {

  static const String _dbName = "bitp3453_bmi";
  static const String _tblName = "bmi";
  static const String _colUsername = "username";
  static const String _colWeight = "weight";
  static const String _colHeight = "height";
  static const String _colGender = "gender";
  static const String _colStatus = "bmi_status";

  Database? _db;

  SQLiteDB._();
  static final SQLiteDB instance = SQLiteDB._();

  factory SQLiteDB() {
    return instance;
  }

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    String path = join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_tblName (
            $_colUsername TEXT,
            $_colWeight REAL,
            $_colHeight REAL,
            $_colGender TEXT,
            $_colStatus TEXT
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertBMIRecord(Map<String, dynamic> row) async {
    Database db = await database;
    await db.insert(_tblName, row);
  }

  Future<List<Map<String, dynamic>>> retrievePreviousData() async {
    Database db = await database;
    return await db.query(_tblName);
  }
}