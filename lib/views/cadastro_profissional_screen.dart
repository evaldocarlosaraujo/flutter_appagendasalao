import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Tela responsável por cadastrar profissionais no sistema.
/// Utilizada pelo administrador para adicionar novos colaboradores.
class CadastroProfissionalScreen extends StatefulWidget {
  @override
  State<CadastroProfissionalScreen> createState() =>
      _CadastroProfissionalScreenState();
}

class _CadastroProfissionalScreenState
    extends State<CadastroProfissionalScreen> {
  // Controllers para capturar o nome e a especialidade digitados
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController especialidadeController = TextEditingController();

  /// Função chamada ao pressionar o botão de salvar.
  /// Valida os campos e salva o profissional no Firestore.
  void salvarProfissional() async {
    // Remove espaços extras dos textos digitados
    String nome = nomeController.text.trim();
    String especialidade = especialidadeController.text.trim();

    // Verifica se os campos estão preenchidos
    if (nome.isEmpty || especialidade.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Preencha todos os campos.")));
      return;
    }

    // Gera um ID único para o novo profissional
    String id = Uuid().v4();

    // Salva o profissional na coleção 'profissionais' no Firestore
    await FirebaseFirestore.instance.collection('profissionais').doc(id).set({
      'id': id,
      'nome': nome,
      'especialidade': especialidade,
    });

    // Exibe mensagem de sucesso
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profissional cadastrado!")));

    // Limpa os campos para permitir novo cadastro
    nomeController.clear();
    especialidadeController.clear();
  }

  /// Interface da tela com formulário simples para cadastro
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Profissional')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para inserir o nome do profissional
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do profissional'),
            ),
            // Campo para inserir a especialidade
            TextField(
              controller: especialidadeController,
              decoration: InputDecoration(labelText: 'Especialidade'),
            ),
            SizedBox(height: 20),
            // Botão que aciona o salvamento no Firestore
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
