import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tarefa.dart';

class TarefaList extends StatelessWidget {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tarefas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('tarefas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var tarefas = snapshot.data!.docs.map((doc) =>
              Tarefa.fromDocumentSnapshot(doc)
          ).toList();

          return ListView.builder(
            itemCount: tarefas.length,
            itemBuilder: (context, index) {
              var tarefa = tarefas[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColor(tarefa.prioridade),
                  child: Text(tarefa.prioridade.toString()),
                ),
                title: Text(tarefa.disciplina),
                subtitle: Text('${tarefa.descricao} - ${tarefa.dataEntrega}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditTarefaDialog(context, tarefa),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTarefa(tarefa.id),
                    ),
                  ],
                ),
                onTap: () => _showViewTarefaDialog(context, tarefa),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTarefaDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getColor(int prioridade) {
    switch (prioridade) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // Janelinha para criar tarefa:
  void _showCreateTarefaDialog(BuildContext context) {
    final disciplinaController = TextEditingController();
    final descricaoController = TextEditingController();
    final dataEntregaController = TextEditingController();
    int prioridadeSelecionada = 2;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Tarefa'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: disciplinaController,
                  decoration: InputDecoration(labelText: 'Disciplina'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                TextField(
                  controller: dataEntregaController,
                  decoration: InputDecoration(labelText: 'Data de Entrega'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Prioridade: '),
                    DropdownButton<int>(
                      value: prioridadeSelecionada,
                      onChanged: (v) => setState(() => prioridadeSelecionada = v!),
                      items: [
                        DropdownMenuItem(value: 1, child: Text('Alta')),
                        DropdownMenuItem(value: 2, child: Text('Média')),
                        DropdownMenuItem(value: 3, child: Text('Baixa')),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Salvar'),
            onPressed: () {
              final disciplina = disciplinaController.text;
              final descricao = descricaoController.text;
              final dataEntrega = dataEntregaController.text;

              if (disciplina.isNotEmpty && descricao.isNotEmpty && dataEntrega.isNotEmpty) {
                _addTarefa(disciplina, descricao, dataEntrega, prioridadeSelecionada);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Todos os campos são obrigatórios')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Janelinha para editar tarefa:
  void _showEditTarefaDialog(BuildContext context, Tarefa tarefa) {
    final disciplinaController = TextEditingController(text: tarefa.disciplina);
    final descricaoController = TextEditingController(text: tarefa.descricao);
    final dataEntregaController = TextEditingController(text: tarefa.dataEntrega);
    int prioridadeSelecionada = tarefa.prioridade;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Tarefa'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: disciplinaController,
                  decoration: InputDecoration(labelText: 'Disciplina'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                TextField(
                  controller: dataEntregaController,
                  decoration: InputDecoration(labelText: 'Data de Entrega'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Prioridade: '),
                    DropdownButton<int>(
                      value: prioridadeSelecionada,
                      onChanged: (v) => setState(() => prioridadeSelecionada = v!),
                      items: [
                        DropdownMenuItem(value: 1, child: Text('Alta')),
                        DropdownMenuItem(value: 2, child: Text('Média')),
                        DropdownMenuItem(value: 3, child: Text('Baixa')),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Salvar'),
            onPressed: () {
              final disciplina = disciplinaController.text;
              final descricao = descricaoController.text;
              final dataEntrega = dataEntregaController.text;

              if (disciplina.isNotEmpty && descricao.isNotEmpty && dataEntrega.isNotEmpty) {
                _updateTarefa(tarefa.id, disciplina, descricao, dataEntrega, prioridadeSelecionada);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Todos os campos são obrigatórios')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Janelinha para visualizar dados da tarefa:
  void _showViewTarefaDialog(BuildContext context, Tarefa tarefa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Visualizar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Disciplina: ${tarefa.disciplina}'),
            Text('Descrição: ${tarefa.descricao}'),
            Text('Data de Entrega: ${tarefa.dataEntrega}'),
            Text('Prioridade: ${tarefa.prioridade}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Grava uma nova tarefa no Firestore:
  void _addTarefa(String disciplina, String descricao, String dataEntrega, int prioridade) {
    _firestore.collection('tarefas').add({
      'disciplina': disciplina,
      'descricao': descricao,
      'dataEntrega': dataEntrega,
      'prioridade': prioridade,
    });
  }

  // Atualiza uma tarefa (com id) no Firestore:
  void _updateTarefa(String id, String disciplina, String descricao, String dataEntrega, int prioridade) {
    _firestore.collection('tarefas').doc(id).update({
      'disciplina': disciplina,
      'descricao': descricao,
      'dataEntrega': dataEntrega,
      'prioridade': prioridade,
    });
  }

  // Apaga uma tarefa com um certo id:
  void _deleteTarefa(String id) {
    _firestore.collection('tarefas').doc(id).delete();
  }
}