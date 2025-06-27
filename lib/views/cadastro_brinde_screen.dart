import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Tela que permite ao administrador cadastrar novos brindes
/// para o programa de fidelidade. Os dados são salvos no Firestore.
class CadastroBrindeScreen extends StatefulWidget {
  @override
  State<CadastroBrindeScreen> createState() => _CadastroBrindeScreenState();
}

class _CadastroBrindeScreenState extends State<CadastroBrindeScreen> {
  // Controllers para capturar os dados dos campos de texto
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _pontosController = TextEditingController();

  /// Função responsável por validar os dados e salvar o brinde no Firestore
  void salvarBrinde() async {
    // Captura e limpa os valores inseridos
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final pontos = int.tryParse(
      _pontosController.text.trim(),
    ); // Converte para int

    // Validação: todos os campos devem estar preenchidos e pontos devem ser número
    if (nome.isEmpty || descricao.isEmpty || pontos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    // Gera um ID único para o brinde usando UUID
    final id = Uuid().v4();

    // Salva o brinde na coleção 'brindes' do Firestore
    await FirebaseFirestore.instance.collection('brindes').doc(id).set({
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'pontosNecessarios': pontos,
    });

    // Mostra mensagem de sucesso
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Brinde cadastrado com sucesso!")));

    // Limpa os campos para permitir novo cadastro
    _nomeController.clear();
    _descricaoController.clear();
    _pontosController.clear();
  }

  /// Interface da tela de cadastro de brindes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Brindes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Campo para digitar o nome do brinde
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Brinde'),
            ),
            // Campo para digitar a descrição do brinde
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            // Campo para digitar os pontos necessários para o resgate
            TextField(
              controller: _pontosController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Pontos Necessários'),
            ),
            SizedBox(height: 20),
            // Botão para acionar a função de salvar
            ElevatedButton(
              onPressed: salvarBrinde,
              child: Text('Salvar Brinde'),
            ),
          ],
        ),
      ),
    );
  }
}
