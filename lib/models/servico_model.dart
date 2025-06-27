/// Modelo que representa um serviço oferecido pelo salão,
/// como depilações, manicure, entre outros.
class Servico {
  // Identificador único do serviço (geralmente gerado automaticamente no Firestore)
  String id;

  // Nome do serviço (ex: Depilação, Manicure)
  String nome;

  // Descrição do serviço (detalhes que ajudam o cliente a entender o que está incluso)
  String descricao;

  // Preço do serviço (armazenado como double para permitir valores com centavos)
  double preco;

  /// Construtor da classe `Servico`, com todos os campos obrigatórios
  Servico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
  });

  /// Converte o objeto `Servico` para um `Map<String, dynamic>`,
  /// formato utilizado para salvar os dados no Firestore.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome, 'descricao': descricao, 'preco': preco};
  }

  /// Método fábrica que cria um objeto `Servico` a partir de um `Map<String, dynamic>`.
  /// Esse método é usado ao recuperar dados salvos no Firestore.
  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      nome: map['nome'],
      descricao: map['descricao'],
      // Garante que o valor seja tratado como double, mesmo que venha como int
      preco: map['preco'].toDouble(),
    );
  }
}
