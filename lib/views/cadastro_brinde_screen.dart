import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CadastroBrindeScreen extends StatefulWidget {
  @override
  State<CadastroBrindeScreen> createState() => _CadastroBrindeScreenState();
}

class _CadastroBrindeScreenState extends State<CadastroBrindeScreen> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _pontosController = TextEditingController();

  void salvarBrinde() async {
    final nome = _nomeController.text.trim();
    final descricao = _descricaoController.text.trim();
    final pontos = int.tryParse(_pontosController.text.trim());

    if (nome.isEmpty || descricao.isEmpty || pontos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    final id = Uuid().v4();
    await FirebaseFirestore.instance.collection('brindes').doc(id).set({
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'pontosNecessarios': pontos,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Brinde cadastrado com sucesso!")));

    _nomeController.clear();
    _descricaoController.clear();
    _pontosController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Brindes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Brinde'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: _pontosController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Pontos Necessários'),
            ),
            SizedBox(height: 20),
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
