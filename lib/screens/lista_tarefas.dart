import 'package:flutter/material.dart';
import '../model/tarefa.dart';
import '../util/dbhelper.dart';
import 'tarefa_detalhe.dart';

// Criando o StatefulWidget
class ListaTarefas extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListaTarefasState();
}

class ListaTarefasState extends State<ListaTarefas> {
  // Atributos
  DbHelper helper = DbHelper();
  List<Tarefa>? tarefas;
  int count = 0;

  void getData() {
    var dbFuture = helper.initializeDb();
    dbFuture.then((result) {
    var tarefasFuture = helper.getTarefas();

      tarefasFuture.then((result) {
        List<Tarefa> tarefaList = [];
        count = result.length;
        for (int i = 0; i < count; i++) {
          tarefaList.add(Tarefa.fromMap(result[i]));
          debugPrint(tarefaList[i].disciplina);
        }
        setState(() {
          tarefas = tarefaList;
        });
        debugPrint("Items " + count.toString());
      });
    });
  }

  void _abreTelaNovaTarefa(BuildContext context) async {
    var resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TarefaDetalhe();
        },
      ),
    );

    if (resultado != null) {
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tarefas == null) {
      tarefas = [];
      getData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas Acadêmicas"),
      ),
      body: tarefaListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _abreTelaNovaTarefa(context);
        },
        tooltip: "Adicionar nova Tarefa",
        child: new Icon(Icons.add),
      ),
    );
  }

  ListView tarefaListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(this.tarefas![position].prioridade),
              child: Text(this.tarefas![position].prioridade.toString()),
            ),
            title: Text(this.tarefas![position].disciplina),
            subtitle: Text(this.tarefas![position].dataEntrega),
            onTap: () {
              debugPrint("Tapped on " + this.tarefas![position].disciplina.toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return TarefaDetalhe(this.tarefas![position]);
                  },
                ),
              ).then((value) {
                if (value != null) {
                  getData();
                }
              });
            },
          ),
        );
      },
    );
  }

  Color getColor(int prioridade) {
    switch (prioridade) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }
}