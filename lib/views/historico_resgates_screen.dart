import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistoricoResgatesScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  Future<String> _buscarNomeBrinde(String brindeId) async {
    if (brindeId.isEmpty) return 'Brinde não informado';
    final doc =
        await FirebaseFirestore.instance
            .collection('brindes')
            .doc(brindeId)
            .get();
    return doc.exists ? doc['nome'] ?? 'Brinde' : 'Brinde removido';
  }

  @override
  Widget build(BuildContext context) {
    final resgatesRef = FirebaseFirestore.instance
        .collection('resgates')
        .where('clienteId', isEqualTo: user!.uid);

    return Scaffold(
      appBar: AppBar(title: Text('Histórico de Resgates')),
      body: StreamBuilder<QuerySnapshot>(
        stream: resgatesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final resgates = snapshot.data!.docs;

          if (resgates.isEmpty) {
            return Center(child: Text('Nenhum resgate encontrado.'));
          }

          return ListView.builder(
            itemCount: resgates.length,
            itemBuilder: (context, index) {
              final resgate = resgates[index];
              final status = resgate['status'];
              final brindeId =
                  resgate.data().toString().contains('brindeId')
                      ? resgate['brindeId']
                      : '';
              final utilizado =
                  resgate.data().toString().contains('utilizado') &&
                  resgate['utilizado'] == true;
              final Timestamp? timestamp = resgate['data'];
              final data = timestamp?.toDate();
              final dataFormatada =
                  data != null
                      ? '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}'
                      : 'Data inválida';

              return FutureBuilder<String>(
                future: _buscarNomeBrinde(brindeId),
                builder: (context, snapshotBrinde) {
                  if (!snapshotBrinde.hasData) {
                    return ListTile(title: Text('Carregando brinde...'));
                  }

                  final nomeBrinde = snapshotBrinde.data!;

                  IconData iconeStatus;
                  Color corStatus;

                  switch (status) {
                    case 'aprovado':
                      iconeStatus = Icons.check_circle;
                      corStatus = Colors.green;
                      break;
                    case 'rejeitado':
                      iconeStatus = Icons.cancel;
                      corStatus = Colors.red;
                      break;
                    default:
                      iconeStatus = Icons.hourglass_top;
                      corStatus = Colors.orange;
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(nomeBrinde),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data: $dataFormatada'),
                          Text(
                            'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                          ),
                          if (status == 'aprovado')
                            Text(
                              utilizado
                                  ? '✅ Brinde utilizado'
                                  : '🎁 Brinde ainda não utilizado',
                            ),
                        ],
                      ),
                      trailing: Icon(iconeStatus, color: corStatus),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
