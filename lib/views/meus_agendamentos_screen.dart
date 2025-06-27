import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeusAgendamentosScreen extends StatefulWidget {
  @override
  _MeusAgendamentosScreenState createState() => _MeusAgendamentosScreenState();
}

class _MeusAgendamentosScreenState extends State<MeusAgendamentosScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  DateTime? selectedDate;
  String selectedStatus = 'Todos';

  /// Cancelar agendamento com confirmação
  void cancelarAgendamentoComConfirmacao(
    String agendamentoId,
    BuildContext context,
  ) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancelar Agendamento'),
            content: Text('Deseja realmente cancelar este agendamento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sim'),
              ),
            ],
          ),
    );

    if (confirmacao == true) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(agendamentoId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento cancelado com sucesso')),
      );
    }
  }

  void mostrarMensagemConfirmado(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendamento confirmado não pode ser cancelado.'),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  /// Filtro de status
  List<String> statusOptions = ['Todos', 'pendente', 'confirmado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus Agendamentos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Filtro por data
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedDate != null
                            ? 'Data: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Selecionar Data',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Filtro por status
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value!),
                  items:
                      statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status[0].toUpperCase() + status.substring(1),
                          ),
                        );
                      }).toList(),
                ),
                IconButton(
                  icon: Icon(Icons.clear),
                  tooltip: 'Limpar Filtros',
                  onPressed:
                      () => setState(() {
                        selectedDate = null;
                        selectedStatus = 'Todos';
                      }),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('agendamentos')
                      .where('clienteId', isEqualTo: userId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                final agendamentosFiltrados =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final dataHora = DateTime.parse(data['dataHora']);
                      final status =
                          data['status']?.toLowerCase() ?? 'pendente';

                      final mesmoDia =
                          selectedDate == null ||
                          (dataHora.year == selectedDate!.year &&
                              dataHora.month == selectedDate!.month &&
                              dataHora.day == selectedDate!.day);

                      final mesmoStatus =
                          selectedStatus == 'Todos' || status == selectedStatus;

                      return mesmoDia && mesmoStatus;
                    }).toList();

                if (agendamentosFiltrados.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum agendamento encontrado com os filtros aplicados.',
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: agendamentosFiltrados.length,
                  itemBuilder: (context, index) {
                    final doc = agendamentosFiltrados[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final dataHora = DateTime.parse(data['dataHora']);
                    final status = data['status']?.toLowerCase() ?? 'pendente';
                    final confirmado = status == 'confirmado';

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(
                          '${data['servicoNome']} com: ${data['profissionalNome']}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dataHora.day}/${dataHora.month} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}',
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                              style: TextStyle(
                                color:
                                    confirmado ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.orange),
                          onPressed: () {
                            if (confirmado) {
                              mostrarMensagemConfirmado(context);
                            } else {
                              cancelarAgendamentoComConfirmacao(
                                doc.id,
                                context,
                              );
                            }
                          },
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
