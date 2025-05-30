import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CadastroServicoScreen extends StatefulWidget {
  @override
  State<CadastroServicoScreen> createState() => _CadastroServicoScreenState();
}

class _CadastroServicoScreenState extends State<CadastroServicoScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();

  void salvarServico() async {
    String nome = nomeController.text.trim();
    String descricao = descricaoController.text.trim();
    double? preco = double.tryParse(precoController.text.trim());

    if (nome.isEmpty || descricao.isEmpty || preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    String id = Uuid().v4();

    await FirebaseFirestore.instance.collection('servicos').doc(id).set({
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Serviço cadastrado com sucesso!")));

    nomeController.clear();
    descricaoController.clear();
    precoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do Serviço'),
            ),
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Preço (R\$)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarServico,
              child: Text('Salvar Serviço'),
            ),
          ],
        ),
      ),
    );
  }
}
