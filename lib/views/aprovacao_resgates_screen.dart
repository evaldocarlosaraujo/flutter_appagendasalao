import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AprovacaoResgatesScreen extends StatelessWidget {
  void _aprovarResgate(String resgateId, String usuarioId) async {
    await FirebaseFirestore.instance
        .collection('resgates')
        .doc(resgateId)
        .update({'status': 'aprovado'});

    // Reduzir os pontos do cliente após a aprovação
    final userDoc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioId)
            .get();

    final pontosAtuais = userDoc.data()?['pontos'] ?? 0;

    // Supondo que os pontos necessários foram salvos na requisição de resgate
    final resgateDoc =
        await FirebaseFirestore.instance
            .collection('resgates')
            .doc(resgateId)
            .get();

    final pontosNecessarios = resgateDoc['pontosNecessarios'] ?? 0;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioId)
        .update({'pontos': pontosAtuais - pontosNecessarios});
  }

  void _rejeitarResgate(String resgateId) async {
    await FirebaseFirestore.instance
        .collection('resgates')
        .doc(resgateId)
        .update({'status': 'rejeitado'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aprovar Resgates')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('resgates')
                .where('status', isEqualTo: 'pendente')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final resgates = snapshot.data!.docs;

          if (resgates.isEmpty)
            return Center(child: Text('Nenhum resgate pendente.'));

          return ListView.builder(
            itemCount: resgates.length,
            itemBuilder: (context, index) {
              final resgate = resgates[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(resgate['brindeNome'] ?? 'Brinde'),
                  subtitle: Text('Usuário: ${resgate['usuarioNome'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed:
                            () => _aprovarResgate(
                              resgate.id,
                              resgate['usuarioId'],
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejeitarResgate(resgate.id),
                      ),
                    ],
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
