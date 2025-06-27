import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Tela que exibe os pontos de fidelidade do cliente,
/// contabilizando agendamentos confirmados e brindes disponíveis,
/// além de permitir solicitar o resgate de brindes.
class MeusPontosScreen extends StatefulWidget {
  @override
  State<MeusPontosScreen> createState() => _MeusPontosScreenState();
}

class _MeusPontosScreenState extends State<MeusPontosScreen> {
  // Quantidade de agendamentos confirmados pelo usuário
  int agendamentosConfirmados = 0;

  // Quantidade de brindes que o usuário pode resgatar
  int brindesDisponiveis = 0;

  @override
  void initState() {
    super.initState();
    // Carrega os dados dos pontos quando a tela é inicializada
    carregarPontos();
  }

  /// Busca no Firestore os agendamentos confirmados do usuário atual
  /// e calcula quantos brindes ele tem direito (1 brinde a cada 10 agendamentos).
  Future<void> carregarPontos() async {
    // Obtém o ID do usuário logado
    final clienteId = FirebaseAuth.instance.currentUser!.uid;

    // Consulta os agendamentos confirmados para esse cliente
    final snapshot =
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .where('clienteId', isEqualTo: clienteId)
            .where('status', isEqualTo: 'confirmado')
            .get();

    // Total de agendamentos confirmados
    final total = snapshot.docs.length;

    // Calcula quantos brindes o usuário tem direito (divisão inteira)
    final brindes = total ~/ 10;

    // Atualiza o estado da tela com os valores obtidos
    setState(() {
      agendamentosConfirmados = total;
      brindesDisponiveis = brindes;
    });
  }

  /// Cria um documento na coleção "resgates" para solicitar um brinde
  /// e atualiza a interface reduzindo os pontos e brindes disponíveis.
  void resgatarBrinde() async {
    final clienteId = FirebaseAuth.instance.currentUser!.uid;

    // Adiciona uma solicitação de resgate com status 'pendente'
    await FirebaseFirestore.instance.collection('resgates').add({
      'clienteId': clienteId,
      'timestamp': Timestamp.now(),
      'status': 'pendente', // será atualizado após aprovação pelo admin
    });

    // Exibe uma mensagem para o usuário confirmando o envio da solicitação
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Solicitação de brinde enviada!")));

    // Atualiza o estado local para refletir o resgate
    setState(() {
      agendamentosConfirmados -= 10; // desconta 10 agendamentos
      brindesDisponiveis -= 1; // desconta 1 brinde disponível
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcula quantos agendamentos faltam para o próximo brinde
    final faltam = 10 - (agendamentosConfirmados % 10);

    return Scaffold(
      appBar: AppBar(title: Text('Meus Pontos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe o total de agendamentos confirmados
            Text(
              'Agendamentos confirmados: $agendamentosConfirmados',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),

            // Exibe quantos brindes estão disponíveis para resgate
            Text(
              'Brindes disponíveis: $brindesDisponiveis',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),

            // Se há brindes para resgatar, mostra o botão para solicitação
            if (brindesDisponiveis > 0)
              ElevatedButton.icon(
                onPressed: resgatarBrinde,
                icon: Icon(Icons.card_giftcard),
                label: Text('Resgatar Brinde'),
              )
            else
              // Se não há brindes disponíveis, informa quantos agendamentos faltam para o próximo
              Text(
                'Faltam $faltam agendamentos para o próximo brinde!',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
