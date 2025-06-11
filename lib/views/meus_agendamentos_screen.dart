import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeusAgendamentosScreen extends StatelessWidget {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void cancelarAgendamento(String agendamentoId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('agendamentos')
        .doc(agendamentoId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento cancelado com sucesso')),
    );
  }

  void mostrarMensagemConfirmado(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendamento confirmado não pode ser cancelado.'),
        backgroundColor: Colors.red[400],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus Agendamentos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('clienteId', isEqualTo: userId)
                //.orderBy('dataHora')
                .snapshots(),
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
                          color: confirmado ? Colors.green : Colors.grey[700],
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
                        cancelarAgendamento(doc.id, context);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
