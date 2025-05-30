class Servico {
  String id;
  String nome;
  String descricao;
  double preco;

  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'descricao': descricao, 'preco': preco};
  }

  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      preco: map['preco'].toDouble(),
    );
  }
}
