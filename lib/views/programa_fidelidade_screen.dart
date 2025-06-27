import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Tela que mostra o programa de fidelidade do usuário:
/// - Quantos pontos ele tem
/// - Brindes disponíveis
/// - Permite selecionar e solicitar resgate de brinde
/// - Mostra brinde aprovado (se houver)
class ProgramaFidelidadeScreen extends StatefulWidget {
  @override
  _ProgramaFidelidadeScreenState createState() =>
      _ProgramaFidelidadeScreenState();
}

class _ProgramaFidelidadeScreenState extends State<ProgramaFidelidadeScreen> {
  int pontos = 0; // Pontuação atual do cliente
  bool podeResgatar = false; // Se já possui pontos suficientes
  String? brindeSelecionadoId; // ID do brinde escolhido pelo usuário
  List<Map<String, dynamic>> brindesDisponiveis =
      []; // Lista de brindes disponíveis
  String? brindeAprovado; // Nome do brinde aprovado mais recente
  bool brindeUtilizado = false; // Se o brinde aprovado já foi usado

  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    carregarPontos(); // Busca a pontuação atual do cliente
    carregarBrindesDisponiveis(); // Carrega os brindes do Firestore
    buscarBrindeAprovado(); // Verifica se há algum brinde aprovado
  }

  /// Busca no Firestore a pontuação do cliente e verifica se já pode resgatar
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

  /// Busca os brindes disponíveis cadastrados no Firestore
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

  /// Verifica se o cliente tem algum resgate aprovado e ainda não utilizado
  Future<void> buscarBrindeAprovado() async {
    final resgatesSnapshot =
        await FirebaseFirestore.instance
            .collection('resgates')
            .where('clienteId', isEqualTo: user!.uid)
            .where('status', isEqualTo: 'aprovado')
            .limit(1)
            .get();

    if (resgatesSnapshot.docs.isNotEmpty) {
      final resgate = resgatesSnapshot.docs.first;

      final brindeId =
          resgate.data().containsKey('brindeId') ? resgate['brindeId'] : null;
      final utilizado =
          resgate.data().containsKey('utilizado')
              ? resgate['utilizado'] == true
              : false;

      if (brindeId != null) {
        final brindeDoc =
            await FirebaseFirestore.instance
                .collection('brindes')
                .doc(brindeId)
                .get();

        setState(() {
          brindeAprovado =
              brindeDoc.exists
                  ? brindeDoc['nome']
                  : 'Brinde removido ou não encontrado';
          brindeUtilizado = utilizado;
        });
      } else {
        setState(() {
          brindeAprovado = 'Brinde não especificado';
        });
      }
    }
  }

  /// Envia solicitação de resgate de brinde para o Firestore
  Future<void> resgatarBrinde() async {
    if (!podeResgatar || brindeSelecionadoId == null) return;

    // Cria um novo documento na coleção "resgates"
    await FirebaseFirestore.instance.collection('resgates').add({
      'clienteId': user!.uid,
      'brindeId': brindeSelecionadoId,
      'data': Timestamp.now(),
      'dataSolicitacao': DateTime.now().toIso8601String(),
      'status': 'pendente',
    });

    // Zera os pontos do cliente após o resgate
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .update({'pontos': 0});

    // Exibe mensagem e atualiza a tela
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
            // Exibe os pontos atuais do usuário
            Text('Seus pontos: $pontos', style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),

            // Dropdown com brindes disponíveis (caso existam)
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

            // Botão de resgate (apenas se puder resgatar)
            ElevatedButton(
              onPressed: podeResgatar ? resgatarBrinde : null,
              child: Text('Resgatar Brinde'),
            ),

            SizedBox(height: 40),

            // Mensagem com o brinde aprovado (se houver)
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

            // Dica sobre como acumular pontos
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
