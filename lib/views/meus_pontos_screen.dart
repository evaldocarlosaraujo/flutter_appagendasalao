import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MeusPontosScreen extends StatefulWidget {
  @override
  State<MeusPontosScreen> createState() => _MeusPontosScreenState();
}

class _MeusPontosScreenState extends State<MeusPontosScreen> {
  int agendamentosConfirmados = 0;
  int brindesDisponiveis = 0;

  @override
  void initState() {
    super.initState();
    carregarPontos();
  }

  Future<void> carregarPontos() async {
    final clienteId = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('agendamentos')
            .where('clienteId', isEqualTo: clienteId)
            .where('status', isEqualTo: 'confirmado')
            .get();

    final total = snapshot.docs.length;
    final brindes = total ~/ 10;

    setState(() {
      agendamentosConfirmados = total;
      brindesDisponiveis = brindes;
    });
  }

  void resgatarBrinde() async {
    final clienteId = FirebaseAuth.instance.currentUser!.uid;

    // Aqui pode ser criado um documento de resgate
    await FirebaseFirestore.instance.collection('resgates').add({
      'clienteId': clienteId,
      'timestamp': Timestamp.now(),
      'status': 'pendente', // ou 'aprovado' depois
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Solicitação de brinde enviada!")));

    // Zera o contador de brindes após o resgate
    setState(() {
      agendamentosConfirmados -= 10;
      brindesDisponiveis -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final faltam = 10 - (agendamentosConfirmados % 10);

    return Scaffold(
      appBar: AppBar(title: Text('Meus Pontos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agendamentos confirmados: $agendamentosConfirmados',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Brindes disponíveis: $brindesDisponiveis',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            if (brindesDisponiveis > 0)
              ElevatedButton.icon(
                onPressed: resgatarBrinde,
                icon: Icon(Icons.card_giftcard),
                label: Text('Resgatar Brinde'),
              )
            else
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
