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
  String? brindeSelecionadoId;
  List<Map<String, dynamic>> brindesDisponiveis = [];
  String? brindeAprovado;
  bool brindeUtilizado = false;

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    carregarPontos();
    carregarBrindesDisponiveis();
    buscarBrindeAprovado();
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

  Future<void> carregarBrindesDisponiveis() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('brindes').get();
    setState(() {
      brindesDisponiveis =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'nome': data['nome'] ?? 'Sem nome',
              'descricao': data['descricao'] ?? '',
              'pontosNecessarios': data['pontosNecessarios'] ?? 10,
            };
          }).toList();
    });
  }

  Future<void> buscarBrindeAprovado() async {
    debugPrint('🔍 Buscando resgates aprovados...');

    final resgatesSnapshot =
        await FirebaseFirestore.instance
            .collection('resgates')
            .where('clienteId', isEqualTo: user!.uid)
            .where('status', isEqualTo: 'aprovado')
            //.orderBy('data', descending: true) // Não usar pois causa erro se não houver índice
            .limit(1)
            .get();

    debugPrint(
      '📦 Total de resgates aprovados encontrados: ${resgatesSnapshot.docs.length}',
    );

    if (resgatesSnapshot.docs.isNotEmpty) {
      final resgate = resgatesSnapshot.docs.first;
      debugPrint('📄 Dados do resgate: ${resgate.data()}');

      final brindeId =
          resgate.data().containsKey('brindeId') ? resgate['brindeId'] : null;
      final utilizado =
          resgate.data().containsKey('utilizado')
              ? resgate['utilizado'] == true
              : false;

      if (brindeId != null) {
        debugPrint('🔑 brindeId encontrado: $brindeId');

        final brindeDoc =
            await FirebaseFirestore.instance
                .collection('brindes')
                .doc(brindeId)
                .get();

        debugPrint(
          '📘 Documento do brinde: ${brindeDoc.exists ? brindeDoc.data() : 'não encontrado'}',
        );

        setState(() {
          brindeAprovado =
              brindeDoc.exists
                  ? brindeDoc['nome']
                  : 'Brinde removido ou não encontrado';
          brindeUtilizado = utilizado;
        });
      } else {
        debugPrint('⚠️ brindeId não encontrado no resgate');
        setState(() {
          brindeAprovado = 'Brinde não especificado';
        });
      }
    } else {
      debugPrint('❌ Nenhum resgate aprovado encontrado');
    }
  }

  Future<void> resgatarBrinde() async {
    if (!podeResgatar || brindeSelecionadoId == null) return;

    await FirebaseFirestore.instance.collection('resgates').add({
      'clienteId': user!.uid,
      'brindeId': brindeSelecionadoId,
      'data': Timestamp.now(),
      'dataSolicitacao': DateTime.now().toIso8601String(),
      'status': 'pendente',
    });

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
      brindeSelecionadoId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Programa de Fidelidade')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Seus pontos: $pontos', style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            if (brindesDisponiveis.isNotEmpty)
              DropdownButtonFormField<String>(
                value: brindeSelecionadoId,
                hint: Text('Selecione um brinde'),
                onChanged:
                    podeResgatar
                        ? (String? value) {
                          setState(() {
                            brindeSelecionadoId = value;
                          });
                        }
                        : null,
                items:
                    brindesDisponiveis.map((brinde) {
                      return DropdownMenuItem<String>(
                        value: brinde['id'],
                        child: Text(
                          '${brinde['nome']} - ${brinde['pontosNecessarios']} pts',
                        ),
                      );
                    }).toList(),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: podeResgatar ? resgatarBrinde : null,
              child: Text('Resgatar Brinde'),
            ),
            SizedBox(height: 40),
            if (brindeAprovado != null)
              Text(
                brindeUtilizado
                    ? '✅ Brinde já utilizado: $brindeAprovado'
                    : '🎁 Você tem um brinde aprovado: $brindeAprovado',
                style: TextStyle(
                  fontSize: 16,
                  color: brindeUtilizado ? Colors.grey : Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 20),
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
