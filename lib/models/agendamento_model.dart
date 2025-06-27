/// Modelo que representa um agendamento feito no aplicativo.
/// Essa classe é usada para organizar e manipular os dados de cada agendamento.
class Agendamento {
  // Identificador único do agendamento
  String id;

  // ID do usuário que realizou o agendamento
  String usuarioId;

  // ID do profissional selecionado
  String profissionalId;

  // Nome do profissional (armazenado para exibição rápida, sem precisar buscar novamente)
  String profissionalNome;

  // ID do serviço escolhido
  String servicoId;

  // Nome do serviço (também armazenado para facilitar exibição)
  String servicoNome;

  // Data e hora do agendamento
  DateTime dataHora;

  /// Construtor da classe `Agendamento`, com todos os campos obrigatórios
  Agendamento({
    required this.id,
    required this.usuarioId,
    required this.profissionalId,
    required this.profissionalNome,
    required this.servicoId,
    required this.servicoNome,
    required this.dataHora,
  });

  /// Método que converte o objeto `Agendamento` para um `Map<String, dynamic>`,
  /// necessário para salvar os dados no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'profissionalId': profissionalId,
      'profissionalNome': profissionalNome,
      'servicoId': servicoId,
      'servicoNome': servicoNome,
      // Converte a data para o formato ISO 8601, compatível com o Firestore
      'dataHora': dataHora.toIso8601String(),
    };
  }

  /// Método fábrica que cria um objeto `Agendamento` a partir de um `Map<String, dynamic>`.
  /// Esse método é útil ao recuperar os dados do Firestore.
  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'],
      usuarioId: map['usuarioId'],
      profissionalId: map['profissionalId'],
      profissionalNome: map['profissionalNome'],
      servicoId: map['servicoId'],
      servicoNome: map['servicoNome'],
      // Converte a string ISO 8601 de volta para um objeto DateTime
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
