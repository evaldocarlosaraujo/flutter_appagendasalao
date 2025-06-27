import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Tela que exibe o histórico de resgates de brindes feitos pelo usuário logado.
class HistoricoResgatesScreen extends StatelessWidget {
  // Obtém o usuário atualmente autenticado
  final user = FirebaseAuth.instance.currentUser;

  /// Busca o nome do brinde a partir do ID.
  /// Caso não encontre, retorna uma mensagem genérica.
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
    // Referência à coleção de resgates do usuário logado
    final resgatesRef = FirebaseFirestore.instance
        .collection('resgates')
        .where('clienteId', isEqualTo: user!.uid);

    return Scaffold(
      appBar: AppBar(title: Text('Histórico de Resgates')),

      // StreamBuilder permite ouvir em tempo real os resgates do usuário
      body: StreamBuilder<QuerySnapshot>(
        stream: resgatesRef.snapshots(),
        builder: (context, snapshot) {
          // Mostra indicador de carregamento enquanto os dados estão sendo buscados
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final resgates = snapshot.data!.docs;

          // Se não houver nenhum resgate, exibe uma mensagem informando
          if (resgates.isEmpty) {
            return Center(child: Text('Nenhum resgate encontrado.'));
          }

          // Lista todos os resgates encontrados
          return ListView.builder(
            itemCount: resgates.length,
            itemBuilder: (context, index) {
              final resgate = resgates[index];

              // Obtém o status do resgate (pendente, aprovado ou rejeitado)
              final status = resgate['status'];

              // Verifica se o campo brindeId está presente
              final brindeId =
                  resgate.data().toString().contains('brindeId')
                      ? resgate['brindeId']
                      : '';

              // Verifica se o brinde já foi utilizado
              final utilizado =
                  resgate.data().toString().contains('utilizado') &&
                  resgate['utilizado'] == true;

              // Converte o timestamp para uma data legível
              final Timestamp? timestamp = resgate['data'];
              final data = timestamp?.toDate();
              final dataFormatada =
                  data != null
                      ? '${data.day}/${data.month}/${data.year} ${data.hour}:${data.minute.toString().padLeft(2, '0')}'
                      : 'Data inválida';

              // Usa FutureBuilder para buscar o nome do brinde de forma assíncrona
              return FutureBuilder<String>(
                future: _buscarNomeBrinde(brindeId),
                builder: (context, snapshotBrinde) {
                  if (!snapshotBrinde.hasData) {
                    return ListTile(title: Text('Carregando brinde...'));
                  }

                  final nomeBrinde = snapshotBrinde.data!;

                  // Define ícone e cor com base no status do resgate
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

                  // Exibe as informações do resgate em um Card
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
