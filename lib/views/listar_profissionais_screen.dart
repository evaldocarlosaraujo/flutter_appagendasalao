import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tela para listar, editar e excluir profissionais cadastrados
class ListarProfissionaisScreen extends StatelessWidget {
  /// Função para excluir profissional pelo ID
  /// Recebe o contexto para mostrar SnackBar com feedback
  void excluirProfissional(String id, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('profissionais')
        .doc(id)
        .delete();

    // Mensagem para confirmar que o profissional foi excluído
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profissional excluído com sucesso!')),
    );
  }

  /// Função que abre um diálogo para editar as informações do profissional
  /// Recebe o contexto e o documento atual do profissional
  void editarProfissional(BuildContext context, DocumentSnapshot doc) {
    // Controladores inicializados com os dados atuais para editar
    final nomeController = TextEditingController(text: doc['nome']);
    final especialidadeController = TextEditingController(
      text: doc['especialidade'],
    );

    // Mostra um diálogo modal para edição
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Profissional'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para editar o nome
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              // Campo para editar a especialidade
              TextField(
                controller: especialidadeController,
                decoration: InputDecoration(labelText: 'Especialidade'),
              ),
            ],
          ),
          actions: [
            // Botão para salvar as alterações no Firestore
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('profissionais')
                    .doc(doc.id)
                    .update({
                      'nome': nomeController.text.trim(),
                      'especialidade': especialidadeController.text.trim(),
                    });

                Navigator.pop(context); // Fecha o diálogo

                // Feedback de sucesso ao usuário
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profissional atualizado com sucesso!'),
                  ),
                );
              },
              child: Text('Salvar'),
            ),
            // Botão para cancelar a edição
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profissionais')),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta em tempo real a coleção 'profissionais'
        stream:
            FirebaseFirestore.instance.collection('profissionais').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          // Caso não tenha profissionais cadastrados
          if (docs.isEmpty) {
            return Center(child: Text('Nenhum profissional cadastrado.'));
          }

          // Lista dinâmica de profissionais com opções de editar e excluir
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return ListTile(
                title: Text(doc['nome']),
                subtitle: Text(doc['especialidade']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão para editar profissional
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editarProfissional(context, doc),
                    ),
                    // Botão para excluir profissional
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirProfissional(doc.id, context),
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
