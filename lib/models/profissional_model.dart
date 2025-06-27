/// Modelo que representa um profissional cadastrado no sistema,
/// como por exemplo cabeleireiro, manicure, etc.
class Profissional {
  // Identificador único do profissional (geralmente gerado via Firestore)
  String id;

  // Nome do profissional
  String nome;

  // Especialidade do profissional (ex: corte de cabelo, unhas, etc.)
  String especialidade;

  /// Construtor da classe `Profissional`, com todos os campos obrigatórios
  Profissional({
    required this.id,
    required this.nome,
    required this.especialidade,
  });

  /// Converte o objeto `Profissional` para um `Map<String, dynamic>`,
  /// necessário para salvar os dados no Firestore.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'especialidade': especialidade};
  }

  /// Método que cria um objeto `Profissional` a partir de um `Map<String, dynamic>`.
  /// Usado ao recuperar os dados salvos no Firestore.
  factory Profissional.fromMap(Map<String, dynamic> map) {
    return Profissional(
      id: map['id'],
      nome: map['nome'],
      especialidade: map['especialidade'],
    );
  }
}
