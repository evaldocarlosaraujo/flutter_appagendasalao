import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResgatesAdminScreen extends StatelessWidget {
  final CollectionReference resgatesRef = FirebaseFirestore.instance.collection(
    'resgates',
  );
  final CollectionReference brindesRef = FirebaseFirestore.instance.collection(
    'brindes',
  );

  void atualizarStatus(
    String resgateId,
    String novoStatus,
    BuildContext context, {
    Map<String, dynamic> extras = const {},
  }) async {
    await resgatesRef.doc(resgateId).update({'status': novoStatus, ...extras});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Resgate $novoStatus com sucesso.')));
  }

  void marcarComoUtilizado(String resgateId, BuildContext context) async {
    await resgatesRef.doc(resgateId).update({'utilizado': true});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Brinde marcado como utilizado.')));
  }

  Future<String> _buscarNomeBrinde(String brindeId) async {
    if (brindeId.isEmpty) return 'Brinde não informado';
    final doc = await brindesRef.doc(brindeId).get();
    return doc.exists ? doc['nome'] ?? 'Brinde' : 'Brinde removido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resgates de Brindes')),
      body: StreamBuilder<QuerySnapshot>(
        stream: resgatesRef.orderBy('data', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final resgates = snapshot.data!.docs;

          if (resgates.isEmpty) {
            return Center(child: Text('Nenhum resgate solicitado.'));
          }

          return ListView.builder(
            itemCount: resgates.length,
            itemBuilder: (context, index) {
              final resgate = resgates[index];
              final status = resgate['status'];
              final utilizado =
                  resgate.data().toString().contains('utilizado') &&
                  resgate['utilizado'] == true;
              final Timestamp? timestamp = resgate['data'];
              final DateTime? data = timestamp?.toDate();

              final dataFormatada =
                  data != null
                      ? '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}'
                      : 'Data inválida';

              final brindeId =
                  resgate.data().toString().contains('brindeId')
                      ? resgate['brindeId']
                      : '';

              return FutureBuilder<String>(
                future: _buscarNomeBrinde(brindeId),
                builder: (context, brindeSnapshot) {
                  if (!brindeSnapshot.hasData) {
                    return ListTile(title: Text('Carregando brinde...'));
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(brindeSnapshot.data!),
                      subtitle: Text(
                        'Solicitado em: $dataFormatada\nStatus: $status${utilizado ? '\n✅ Já utilizado' : ''}',
                      ),
                      isThreeLine: true,
                      trailing:
                          status == 'pendente'
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'Aprovar',
                                    onPressed:
                                        () => atualizarStatus(
                                          resgate.id,
                                          'aprovado',
                                          context,
                                        ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    tooltip: 'Rejeitar',
                                    onPressed:
                                        () => atualizarStatus(
                                          resgate.id,
                                          'rejeitado',
                                          context,
                                        ),
                                  ),
                                ],
                              )
                              : status == 'aprovado'
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: Colors.green),
                                  SizedBox(width: 8),
                                  if (!utilizado)
                                    TextButton.icon(
                                      icon: Icon(Icons.check_circle_outline),
                                      label: Text('Utilizado'),
                                      onPressed:
                                          () => marcarComoUtilizado(
                                            resgate.id,
                                            context,
                                          ),
                                    ),
                                ],
                              )
                              : Icon(Icons.block, color: Colors.red),
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
