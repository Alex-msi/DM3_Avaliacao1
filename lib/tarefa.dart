import 'package:cloud_firestore/cloud_firestore.dart';

class Tarefa {
  late String id;
  late String disciplina;
  late String descricao;
  late String dataEntrega;
  late int prioridade;

  Tarefa(this.id, this.disciplina, this.descricao, this.dataEntrega, this.prioridade);

  // Construtor nomeado para criar uma Tarefa a partir de um DocumentSnapshot:
  Tarefa.fromDocumentSnapshot(DocumentSnapshot doc) {
    id = doc.id;
    disciplina = doc['disciplina'] as String;
    descricao = doc['descricao'] as String;
    dataEntrega = doc['dataEntrega'] as String;
    prioridade = doc['prioridade'] as int;
  }
}