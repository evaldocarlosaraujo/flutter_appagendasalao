class Profissional {
  String id;
  String nome;
  String especialidade;

  Profissional({
    required this.id,
    required this.nome,
    required this.especialidade,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'especialidade': especialidade};
  }

  factory Profissional.fromMap(Map<String, dynamic> map) {
    return Profissional(
      id: map['id'],
      nome: map['nome'],
      especialidade: map['especialidade'],
    );
  }
}
