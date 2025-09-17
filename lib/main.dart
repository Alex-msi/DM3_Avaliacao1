import 'package:flutter/material.dart';
import 'screens/lista_tarefas.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarefas Acadêmicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListaTarefas(),
    );
  }
}