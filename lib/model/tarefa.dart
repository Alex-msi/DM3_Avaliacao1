class Tarefa {
  // Atributos:
  int? _id;
  String _disciplina;
  String _descricao;
  String _dataEntrega;
  int _prioridade; // 1=Alta, 2=Média, 3=Baixa

  // Construtor
  Tarefa(this._disciplina, this._descricao, this._dataEntrega, this._prioridade);


  // Named constructor
  Tarefa.withId(this._id, this._disciplina, this._descricao, this._dataEntrega, this._prioridade);

  // Getters...
  int? get id => _id;
  String get disciplina => _disciplina;
  String get descricao => _descricao;
  String get dataEntrega => _dataEntrega;
  int get prioridade => _prioridade;

  // Setters...
  set disciplina(String newDisciplina) {
    if (newDisciplina.length <= 255) {
      _disciplina = newDisciplina;
    }
  }

  set descricao(String newDescricao) {
    if (newDescricao.length <= 255) {
      _descricao = newDescricao;
    }
  }

  set dataEntrega(String newDataEntrega) {
    _dataEntrega = newDataEntrega;
  }

  set prioridade(int newPrioridade) {
    if (newPrioridade > 0 && newPrioridade <= 3) {
      _prioridade = newPrioridade;
    }
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["disciplina"] = _disciplina;
    map["descricao"] = _descricao;
    map["dataEntrega"] = _dataEntrega;
    map["prioridade"] = _prioridade;
    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  Tarefa.fromMap(Map<String, dynamic> o)
      : _id = o["id"],
        _disciplina = o["disciplina"],
        _descricao = o["descricao"],
        _dataEntrega = o["dataEntrega"],
        _prioridade = o["prioridade"];
}