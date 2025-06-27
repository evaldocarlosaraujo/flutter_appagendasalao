import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela destinada ao administrador para aprovar ou rejeitar
/// solicitações de resgate de brindes feitas pelos clientes.
/// Exibe apenas resgates com status "pendente".
class AprovacaoResgatesScreen extends StatelessWidget {
  /// Função chamada ao aprovar um resgate.
  /// Atualiza o status do resgate no Firestore e desconta os pontos do cliente.
  void _aprovarResgate(String resgateId, String usuarioId) async {
    // Atualiza o status do resgate para "aprovado"
    await FirebaseFirestore.instance
        .collection('resgates')
        .doc(resgateId)
        .update({'status': 'aprovado'});

    // Busca os dados do usuário para obter os pontos atuais
    final userDoc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioId)
            .get();

    final pontosAtuais = userDoc.data()?['pontos'] ?? 0;

    // Busca o resgate para saber quantos pontos devem ser descontados
    final resgateDoc =
        await FirebaseFirestore.instance
            .collection('resgates')
            .doc(resgateId)
            .get();

    final pontosNecessarios = resgateDoc['pontosNecessarios'] ?? 0;

    // Atualiza o total de pontos do cliente
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuarioId)
        .update({'pontos': pontosAtuais - pontosNecessarios});
  }

  /// Função chamada ao rejeitar um resgate.
  /// Apenas altera o status para "rejeitado".
  void _rejeitarResgate(String resgateId) async {
    await FirebaseFirestore.instance
        .collection('resgates')
        .doc(resgateId)
        .update({'status': 'rejeitado'});
  }

  /// Interface da tela
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Aprovar Resgates')),

      // StreamBuilder para escutar em tempo real os resgates pendentes
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

          // Lista de resgates pendentes
          return ListView.builder(
            itemCount: resgates.length,
            itemBuilder: (context, index) {
              final resgate = resgates[index];

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  // Exibe nome do brinde e nome do usuário
                  title: Text(resgate['brindeNome'] ?? 'Brinde'),
                  subtitle: Text('Usuário: ${resgate['usuarioNome'] ?? ''}'),

                  // Botões de ação: aprovar ou rejeitar
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        tooltip: 'Aprovar',
                        onPressed:
                            () => _aprovarResgate(
                              resgate.id,
                              resgate['usuarioId'],
                            ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        tooltip: 'Rejeitar',
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
