class Agendamento {
  String id;
  String usuarioId;
  String profissionalId;
  String profissionalNome;
  String servicoId;
  String servicoNome;
  DateTime dataHora;

  Agendamento({
    required this.id,
    required this.usuarioId,
    required this.profissionalId,
    required this.profissionalNome,
    required this.servicoId,
    required this.servicoNome,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'profissionalId': profissionalId,
      'profissionalNome': profissionalNome,
      'servicoId': servicoId,
      'servicoNome': servicoNome,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id'],
      usuarioId: map['usuarioId'],
      profissionalId: map['profissionalId'],
      profissionalNome: map['profissionalNome'],
      servicoId: map['servicoId'],
      servicoNome: map['servicoNome'],
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
