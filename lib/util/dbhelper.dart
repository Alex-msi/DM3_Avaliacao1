import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/tarefa.dart';

class DbHelper {
  String tblTarefa = "tarefa";
  String colId = "id";
  String colDisciplina = "disciplina";
  String colDescricao = "descricao";
  String colDataEntrega = "dataEntrega";
  String colPrioridade = "prioridade";

  DbHelper._internal();

  static final DbHelper _dbHelper = DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database? _db;

  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "tarefas.db";
    var dbTarefas = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTarefas;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblTarefa($colId INTEGER PRIMARY KEY, $colDisciplina TEXT, " +
            "$colDescricao TEXT, $colDataEntrega TEXT, $colPrioridade INTEGER)");
  }

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db!;
  }

  Future<int> insertTarefa(Tarefa tarefa) async {
    Database db = await this.db;
    var result = await db.insert(tblTarefa, tarefa.toMap());
    return result;
  }

  Future<List> getTarefas() async {
    Database db = await this.db;
    var result = await db.rawQuery("SELECT * FROM $tblTarefa order by $colPrioridade ASC");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("select count (*) from $tblTarefa"));
    return result!;
  }

  Future<int> updateTarefa(Tarefa tarefa) async {
    var db = await this.db;
    var result = await db.update(tblTarefa,
        tarefa.toMap(),
        where: "$colId = ?",
        whereArgs: [tarefa.id]);
    return result;
  }

  Future<int> deleteTarefa(int id) async {
    int result;
    var db = await this.db;
    result = await db.rawDelete('DELETE FROM $tblTarefa WHERE $colId = $id');
    return result;
  }
}