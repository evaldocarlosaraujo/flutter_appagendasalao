import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

/// Tela de cadastro de um novo serviço que será oferecido no salão.
/// O serviço é salvo no Firestore com um ID único, nome, descrição e preço.
class CadastroServicoScreen extends StatefulWidget {
  @override
  State<CadastroServicoScreen> createState() => _CadastroServicoScreenState();
}

class _CadastroServicoScreenState extends State<CadastroServicoScreen> {
  // Controllers para capturar os dados digitados pelo usuário
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  final TextEditingController precoController = TextEditingController();

  /// Função responsável por validar e salvar os dados do serviço no Firestore
  void salvarServico() async {
    // Lê os dados dos campos e remove espaços em branco
    String nome = nomeController.text.trim();
    String descricao = descricaoController.text.trim();
    double? preco = double.tryParse(
      precoController.text.trim(),
    ); // Converte texto para número decimal

    // Verifica se todos os campos foram preenchidos corretamente
    if (nome.isEmpty || descricao.isEmpty || preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Preencha todos os campos corretamente.")),
      );
      return;
    }

    // Gera um ID único para o novo serviço
    String id = Uuid().v4();

    // Salva os dados no Firestore, na coleção 'servicos'
    await FirebaseFirestore.instance.collection('servicos').doc(id).set({
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
    });

    // Mostra mensagem de sucesso
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Serviço cadastrado com sucesso!")));

    // Limpa os campos após o cadastro
    nomeController.clear();
    descricaoController.clear();
    precoController.clear();
  }

  /// Constrói a interface da tela de cadastro
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo: Nome do serviço
            TextField(
              controller: nomeController,
              decoration: InputDecoration(labelText: 'Nome do Serviço'),
            ),

            // Campo: Descrição
            TextField(
              controller: descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),

            // Campo: Preço (com suporte a números decimais)
            TextField(
              controller: precoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Preço (R\$)'),
            ),

            SizedBox(height: 20),

            // Botão para salvar o serviço
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
