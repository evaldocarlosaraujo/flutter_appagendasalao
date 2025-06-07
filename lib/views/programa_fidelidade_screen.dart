import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgramaFidelidadeScreen extends StatefulWidget {
  @override
  _ProgramaFidelidadeScreenState createState() =>
      _ProgramaFidelidadeScreenState();
}

class _ProgramaFidelidadeScreenState extends State<ProgramaFidelidadeScreen> {
  int pontos = 0;
  bool podeResgatar = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    carregarPontos();
  }

  Future<void> carregarPontos() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        pontos = data['pontos'] ?? 0;
        podeResgatar = pontos >= 10;
      });
    }
  }

  Future<void> resgatarBrinde() async {
    if (!podeResgatar) return;

    // Registra o resgate em uma nova coleção
    await FirebaseFirestore.instance.collection('resgates').add({
      'clienteId': user!.uid,
      'data': Timestamp.now(),
      'status': 'pendente',
    });

    // Zera os pontos
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .update({'pontos': 0});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Brinde solicitado com sucesso! Aguarde aprovação.'),
      ),
    );

    setState(() {
      pontos = 0;
      podeResgatar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Programa de Fidelidade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Seus pontos: $pontos', style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: podeResgatar ? resgatarBrinde : null,
              child: Text('Resgatar Brinde'),
            ),
            SizedBox(height: 40),
            Text(
              'A cada 10 agendamentos confirmados você ganha um brinde!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
