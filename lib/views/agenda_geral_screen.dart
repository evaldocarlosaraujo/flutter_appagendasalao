import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela da Agenda Geral, acessada pelo administrador para visualizar,
/// confirmar ou cancelar agendamentos. Possui filtros por profissional e data.
class AgendaGeralScreen extends StatefulWidget {
  @override
  State<AgendaGeralScreen> createState() => _AgendaGeralScreenState();
}

class _AgendaGeralScreenState extends State<AgendaGeralScreen> {
  // ID do profissional selecionado no filtro
  String? profissionalSelecionadoId;

  // Data selecionada no filtro
  DateTime? dataSelecionada;

  /// Função responsável por cancelar um agendamento.
  /// Exibe um diálogo de confirmação e, se confirmado,
  /// remove o agendamento do Firestore.
  /// Se o agendamento estiver confirmado, remove 1 ponto do cliente.
  void cancelarAgendamento(String agendamentoId, BuildContext context) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar cancelamento'),
            content: Text('Deseja realmente cancelar o agendamento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sim'),
              ),
            ],
          ),
    );

    // Cancela apenas se o usuário confirmar
    if (confirmacao != true) return;

    final agendamentoRef = FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId);

    final agendamentoSnapshot = await agendamentoRef.get();

    if (agendamentoSnapshot.exists) {
      final agendamentoData = agendamentoSnapshot.data()!;
      final status = agendamentoData['status'];
      final clienteId = agendamentoData['clienteId'];

      // Se estava confirmado, remover ponto do cliente
      if (status == 'confirmado' && clienteId != null) {
        final usuarioRef = FirebaseFirestore.instance
            .collection('usuarios')
            .doc(clienteId);
        await usuarioRef.update({'pontos': FieldValue.increment(-1)});
      }

      // Remove o agendamento do banco
      await agendamentoRef.delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento cancelado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Agendamento não encontrado.')));
    }
  }

  /// Confirma um agendamento, atualizando o status no banco
  /// e adicionando 1 ponto ao cliente.
  void confirmarAgendamento(
    String agendamentoId,
    String clienteId,
    BuildContext context,
  ) async {
    final agendamentoRef = FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId);

    final usuarioRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(clienteId);

    await agendamentoRef.update({'status': 'confirmado'});
    await usuarioRef.update({'pontos': FieldValue.increment(1)});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento confirmado e ponto adicionado.')),
    );
  }

  /// Recupera os agendamentos em tempo real aplicando os filtros de profissional e data.
  Stream<QuerySnapshot> _agendamentosFiltrados() {
    final ref = FirebaseFirestore.instance.collection('agendamentos');
    Query query = ref;

    if (profissionalSelecionadoId != null) {
      query = query.where(
        'profissionalId',
        isEqualTo: profissionalSelecionadoId,
      );
    }

    if (dataSelecionada != null) {
      final inicio = DateTime(
        dataSelecionada!.year,
        dataSelecionada!.month,
        dataSelecionada!.day,
      );
      final fim = inicio.add(Duration(days: 1));

      query = query
          .where('dataHora', isGreaterThanOrEqualTo: inicio.toIso8601String())
          .where('dataHora', isLessThan: fim.toIso8601String());
    }

    return query.snapshots();
  }

  /// Busca os dados do cliente (nome e telefone) com base no ID fornecido.
  Future<Map<String, String>> _buscarDadosCliente(String clienteId) async {
    final usuarioSnapshot =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(clienteId)
            .get();

    if (usuarioSnapshot.exists) {
      final data = usuarioSnapshot.data()!;
      return {
        'nome': data['nome'] ?? 'Cliente',
        'telefone': data['telefone'] ?? 'Não informado',
      };
    } else {
      return {'nome': 'Cliente', 'telefone': 'Não encontrado'};
    }
  }

  /// Monta a interface da tela principal da Agenda Geral.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agenda Geral')),
      body: Column(
        children: [
          // Área de filtros
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filtro por profissional usando Dropdown
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('profissionais')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final profissionais = snapshot.data!.docs;

                    return DropdownButton<String>(
                      value: profissionalSelecionadoId,
                      hint: Text('Filtrar por Profissional'),
                      isExpanded: true,
                      items:
                          profissionais.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['id'],
                              child: Text(doc['nome']),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => profissionalSelecionadoId = value);
                      },
                    );
                  },
                ),
                SizedBox(height: 10),
                // Filtro por data
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          DateTime? data = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (data != null) {
                            setState(() => dataSelecionada = data);
                          }
                        },
                        child: Text(
                          dataSelecionada == null
                              ? 'Filtrar por Data'
                              : '${dataSelecionada!.day}/${dataSelecionada!.month}/${dataSelecionada!.year}',
                        ),
                      ),
                    ),
                    // Botão de limpar filtros
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          dataSelecionada = null;
                          profissionalSelecionadoId = null;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de agendamentos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _agendamentosFiltrados(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final agendamentos = snapshot.data!.docs;

                if (agendamentos.isEmpty) {
                  return Center(child: Text('Nenhum agendamento encontrado.'));
                }

                return ListView.builder(
                  itemCount: agendamentos.length,
                  itemBuilder: (context, index) {
                    final doc = agendamentos[index];
                    final dataHora = DateTime.tryParse(doc['dataHora']);
                    final status = doc['status'] ?? 'pendente';
                    final clienteId = doc['clienteId'];

                    return FutureBuilder<Map<String, String>>(
                      future: _buscarDadosCliente(clienteId),
                      builder: (context, snapshotCliente) {
                        final nomeCliente =
                            snapshotCliente.data?['nome'] ?? 'Cliente';
                        final telefoneCliente =
                            snapshotCliente.data?['telefone'] ?? '...';

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              '${doc['servicoNome']} com: ${doc['profissionalNome']}',
                            ),
                            subtitle: Text(
                              '${dataHora != null ? '${dataHora.day}/${dataHora.month} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}' : 'Data inválida'}\n'
                              'Cliente: $nomeCliente\nTelefone: $telefoneCliente',
                            ),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                // Botão para confirmar agendamento (se estiver pendente)
                                if (status == 'pendente')
                                  IconButton(
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Confirmar Agendamento',
                                    onPressed:
                                        () => confirmarAgendamento(
                                          doc.id,
                                          clienteId,
                                          context,
                                        ),
                                  ),
                                // Botão para cancelar agendamento
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  tooltip: 'Cancelar Agendamento',
                                  onPressed:
                                      () =>
                                          cancelarAgendamento(doc.id, context),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
