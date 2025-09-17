import 'package:flutter/material.dart';
import '../model/tarefa.dart';
import '../util/dbhelper.dart';

// StatefulWidget
class TarefaDetalhe extends StatefulWidget {
  Tarefa? tarefa;

  TarefaDetalhe([this.tarefa]);

  @override
  State createState() => TarefaDetalheState();
}

class TarefaDetalheState extends State<TarefaDetalhe> {
  TextStyle estilo = TextStyle(fontSize: 20.0);
  TextEditingController tcDisciplina = TextEditingController();
  TextEditingController tcDescricao = TextEditingController();
  TextEditingController tcDataEntrega = TextEditingController();

  DbHelper helper = DbHelper();
  int prioridadeSelecionada = 2;

  InputDecoration decora(String t) {
    return InputDecoration(
      hintStyle: TextStyle(fontSize: 20.0),
      hintText: t,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      tcDisciplina.text = widget.tarefa!.disciplina;
      tcDescricao.text = widget.tarefa!.descricao;
      tcDataEntrega.text = widget.tarefa!.dataEntrega;
      prioridadeSelecionada = widget.tarefa!.prioridade;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova Tarefa' : 'Detalhes da Tarefa'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tcDisciplina,
                decoration: decora("Disciplina"),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tcDescricao,
                decoration: decora("Descrição da tarefa"),
                maxLines: 3,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tcDataEntrega,
                decoration: decora("Data (15/05/2025)"),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text('Prioridade: ', style: estilo),
                  DropdownButton<int>(
                    value: prioridadeSelecionada,
                    onChanged: (int? newValue) {
                      setState(() {
                        prioridadeSelecionada = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem(value: 1, child: Text('Alta (1)')),
                      DropdownMenuItem(value: 2, child: Text('Média (2)')),
                      DropdownMenuItem(value: 3, child: Text('Baixa (3)')),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  ElevatedButton(
                    child: Text('SALVAR'),
                    onPressed: () {
                      _salvarTarefa();
                    },
                  ),

                  if (widget.tarefa != null)
                    ElevatedButton(
                      child: Text('EXCLUIR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        _confirmarExclusao();
                      },
                    ),

                  ElevatedButton(
                    child: Text('CANCELAR'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarTarefa() async {
    if (tcDisciplina.text.isEmpty || tcDescricao.text.isEmpty || tcDataEntrega.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos!'),
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    if (widget.tarefa == null) {
      Tarefa novaTarefa = Tarefa(
        tcDisciplina.text,
        tcDescricao.text,
        tcDataEntrega.text,
        prioridadeSelecionada,
      );

      int resultado = await helper.insertTarefa(novaTarefa);

      if (resultado > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa salva com sucesso!')),
        );
        Navigator.pop(context, "saved");
      }
    } else {
      widget.tarefa!.disciplina = tcDisciplina.text;
      widget.tarefa!.descricao = tcDescricao.text;
      widget.tarefa!.dataEntrega = tcDataEntrega.text;
      widget.tarefa!.prioridade = prioridadeSelecionada;

      int resultado = await helper.updateTarefa(widget.tarefa!);

      if (resultado > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa atualizada com sucesso!')),
        );
        Navigator.pop(context, "updated");
      }
    }
  }

  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir esta tarefa?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _excluirTarefa();
              },
            ),
          ],
        );
      },
    );
  }

  void _excluirTarefa() async {
    if (widget.tarefa != null && widget.tarefa!.id != null) {
      int resultado = await helper.deleteTarefa(widget.tarefa!.id!);

      if (resultado > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tarefa excluída com sucesso!')),
        );
        Navigator.pop(context, "deleted");
      }
    }
  }
}