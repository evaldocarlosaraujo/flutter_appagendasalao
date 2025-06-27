import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Tela que mostra os agendamentos do usuário logado,
/// permitindo cancelar agendamentos pendentes.
class MeusAgendamentosScreen extends StatelessWidget {
  // Pega o ID do usuário atual logado via FirebaseAuth
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  /// Função que exibe uma confirmação antes de cancelar o agendamento.
  /// Se confirmado, deleta o agendamento no Firestore.
  void cancelarAgendamentoComConfirmacao(
    String agendamentoId,
    BuildContext context,
  ) async {
    // Exibe diálogo para confirmar ação do usuário
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Cancelar Agendamento'),
            content: Text('Deseja realmente cancelar este agendamento?'),
            actions: [
              TextButton(
                onPressed:
                    () => Navigator.pop(context, false), // Usuário cancelou
                child: Text('Não'),
              ),
              ElevatedButton(
                onPressed:
                    () => Navigator.pop(context, true), // Usuário confirmou
                child: Text('Sim'),
              ),
            ],
          ),
    );

    // Se usuário confirmou, prossegue para deletar
    if (confirmacao == true) {
      await FirebaseFirestore.instance
          .collection('agendamentos')
          .doc(agendamentoId)
          .delete();

      // Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento cancelado com sucesso')),
      );
    }
  }

  /// Exibe mensagem informando que agendamento confirmado não pode ser cancelado.
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
        // Escuta em tempo real os agendamentos do usuário atual
        stream:
            FirebaseFirestore.instance
                .collection('agendamentos')
                .where('clienteId', isEqualTo: userId)
                //.orderBy('dataHora') // Pode ordenar futuramente por data e hora
                .snapshots(),
        builder: (context, snapshot) {
          // Enquanto não tem dados, mostra indicador de carregamento
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final agendamentos = snapshot.data!.docs;

          // Caso não haja agendamentos, informa ao usuário
          if (agendamentos.isEmpty) {
            return Center(child: Text('Nenhum agendamento encontrado.'));
          }

          // Lista os agendamentos em uma ListView
          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final doc = agendamentos[index];
              final data = doc.data() as Map<String, dynamic>;

              // Converte string para DateTime para exibir data/hora formatados
              final dataHora = DateTime.parse(data['dataHora']);
              // Status pode ser: pendente, confirmado, etc.
              final status = data['status']?.toLowerCase() ?? 'pendente';
              // Verifica se está confirmado para bloquear cancelamento
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
                      // Mostra data e hora formatadas
                      Text(
                        '${dataHora.day}/${dataHora.month} às ${dataHora.hour}:${dataHora.minute.toString().padLeft(2, '0')}',
                      ),
                      SizedBox(height: 4),
                      // Exibe status com cor diferente se confirmado ou pendente
                      Text(
                        'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                        style: TextStyle(
                          color: confirmado ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Botão para cancelar agendamento (se permitido)
                  trailing: IconButton(
                    icon: Icon(Icons.cancel, color: Colors.orange),
                    onPressed: () {
                      if (confirmado) {
                        // Se confirmado, mostra aviso que não pode cancelar
                        mostrarMensagemConfirmado(context);
                      } else {
                        // Senão, mostra diálogo de confirmação e cancela
                        cancelarAgendamentoComConfirmacao(doc.id, context);
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
