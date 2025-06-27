import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela de listagem e gerenciamento dos brindes cadastrados
class ListarBrindesScreen extends StatefulWidget {
  @override
  State<ListarBrindesScreen> createState() => _ListarBrindesScreenState();
}

class _ListarBrindesScreenState extends State<ListarBrindesScreen> {
  // Referência para a coleção de brindes no Firestore
  final CollectionReference brindesRef = FirebaseFirestore.instance.collection(
    'brindes',
  );

  /// Função para excluir um brinde, com confirmação do usuário
  void excluirBrinde(String id) async {
    // Mostra um diálogo para confirmar se o usuário realmente quer excluir
    final confirmacao = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmar exclusão'),
            content: Text('Deseja realmente excluir este brinde?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Não'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Sim'),
              ),
            ],
          ),
    );

    // Se o usuário confirmou a exclusão, apaga o documento no Firestore
    if (confirmacao == true) {
      await brindesRef.doc(id).delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Brinde excluído com sucesso.')));
    }
  }

  /// Função que abre um modal para editar um brinde já cadastrado
  void editarBrinde(String id, String nomeAtual, String descricaoAtual) {
    // Controladores preenchidos com os valores atuais do brinde
    TextEditingController nomeController = TextEditingController(
      text: nomeAtual,
    );
    TextEditingController descricaoController = TextEditingController(
      text: descricaoAtual,
    );

    // Mostra o diálogo de edição
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Editar Brinde'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Atualiza os dados do brinde no Firestore
                  await brindesRef.doc(id).update({
                    'nome': nomeController.text,
                    'descricao': descricaoController.text,
                  });
                  Navigator.pop(context); // Fecha o diálogo

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Brinde atualizado com sucesso.')),
                  );
                },
                child: Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar Brindes')),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta em tempo real os documentos da coleção "brindes"
        stream: brindesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final brindes = snapshot.data!.docs;

          // Caso não tenha nenhum brinde cadastrado
          if (brindes.isEmpty) {
            return Center(child: Text('Nenhum brinde cadastrado.'));
          }

          // Lista todos os brindes com opção de editar ou excluir
          return ListView.builder(
            itemCount: brindes.length,
            itemBuilder: (context, index) {
              final brinde = brindes[index];

              return ListTile(
                title: Text(brinde['nome']),
                subtitle: Text(brinde['descricao']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão de editar brinde
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => editarBrinde(
                            brinde.id,
                            brinde['nome'],
                            brinde['descricao'],
                          ),
                    ),
                    // Botão de excluir brinde
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirBrinde(brinde.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
