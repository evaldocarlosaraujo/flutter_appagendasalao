import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CadastroProfissionalScreen extends StatefulWidget {
  @override
  State<CadastroProfissionalScreen> createState() =>
      _CadastroProfissionalScreenState();
}

class _CadastroProfissionalScreenState
    extends State<CadastroProfissionalScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController especialidadeController = TextEditingController();

  void salvarProfissional() async {
    String nome = nomeController.text.trim();
    String especialidade = especialidadeController.text.trim();

    if (nome.isEmpty || especialidade.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }

    String id = Uuid().v4(); // cria um ID único

    await FirebaseFirestore.instance.collection('profissionais').doc(id).set({
      'id': id,
      'nome': nome,
      'especialidade': especialidade,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profissional cadastrado!")));

    nomeController.clear();
    especialidadeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Profissional')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do profissional'),
            ),
            TextField(
              controller: especialidadeController,
              decoration: InputDecoration(labelText: 'Especialidade'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: salvarProfissional,
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
