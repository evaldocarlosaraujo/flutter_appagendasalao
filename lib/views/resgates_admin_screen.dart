import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela utilizada pelo ADMINISTRADOR para gerenciar as solicitações de resgate de brindes:
/// - Visualiza todos os resgates solicitados
/// - Pode aprovar, rejeitar ou marcar como utilizado
class ResgatesAdminScreen extends StatelessWidget {
  // Referência à coleção de resgates no Firestore
  final CollectionReference resgatesRef = FirebaseFirestore.instance.collection(
    'resgates',
  );

  // Referência à coleção de brindes
  final CollectionReference brindesRef = FirebaseFirestore.instance.collection(
    'brindes',
  );

  /// Atualiza o status do resgate (pendente, aprovado, rejeitado)
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

  /// Marca o resgate como utilizado (após o cliente receber o brinde)
  void marcarComoUtilizado(String resgateId, BuildContext context) async {
    await resgatesRef.doc(resgateId).update({'utilizado': true});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Brinde marcado como utilizado.')));
  }

  /// Busca o nome do brinde com base no ID salvo no documento de resgate
  Future<String> _buscarNomeBrinde(String brindeId) async {
    if (brindeId.isEmpty) return 'Brinde não informado';
    final doc = await brindesRef.doc(brindeId).get();
    return doc.exists ? doc['nome'] ?? 'Brinde' : 'Brinde removido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resgates de Brindes')),

      // StreamBuilder para escutar os resgates em tempo real
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

              // FutureBuilder interno para buscar o nome do brinde por ID
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
                        'Solicitado em: $dataFormatada\n'
                        'Status: $status${utilizado ? '\n✅ Já utilizado' : ''}',
                      ),
                      isThreeLine: true,

                      // Ações disponíveis dependendo do status
                      trailing:
                          status == 'pendente'
                              ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Botão Aprovar
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
                                  // Botão Rejeitar
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
                                  // Botão "Marcar como utilizado" (aparece apenas se ainda não foi utilizado)
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
                              : Icon(
                                Icons.block,
                                color: Colors.red,
                              ), // Ícone de rejeitado
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
