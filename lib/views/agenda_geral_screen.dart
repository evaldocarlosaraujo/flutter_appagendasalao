import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgendaGeralScreen extends StatefulWidget {
  @override
  State<AgendaGeralScreen> createState() => _AgendaGeralScreenState();
}

class _AgendaGeralScreenState extends State<AgendaGeralScreen> {
  String? profissionalSelecionadoId;
  DateTime? dataSelecionada;

  void cancelarAgendamento(String agendamentoId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento cancelado com sucesso')),
    );
  }

  Stream<QuerySnapshot> _agendamentosFiltrados() {
    final ref = FirebaseFirestore.instance.collection('agendamentos');

    Query query = ref; //.orderBy('dataHora');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agenda Geral')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Filtro por profissional
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
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed:
                          () => setState(() {
                            dataSelecionada = null;
                            profissionalSelecionadoId = null;
                          }),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Agendamentos
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

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(
                          '${doc['servicoNome']} com: ${doc['profissionalNome']}',
                        ),
                        subtitle: Text(
                          dataHora != null
                              ? '${dataHora.day}/${dataHora.month} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}'
                              : 'Data inválida',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => cancelarAgendamento(doc.id, context),
                        ),
                      ),
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
