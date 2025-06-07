// ignore_for_file: unnecessary_null_comparison

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus Agendamentos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('usuarioId', isEqualTo: userId)
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
              final dataHora = DateTime.parse(doc['dataHora']);

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
                    icon: Icon(Icons.cancel, color: Colors.orange),
                    onPressed: () => cancelarAgendamento(doc.id, context),
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
