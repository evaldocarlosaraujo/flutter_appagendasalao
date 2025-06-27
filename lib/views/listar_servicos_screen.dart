import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tela para listar, editar e excluir serviços cadastrados
class ListarServicosScreen extends StatelessWidget {
  /// Função para excluir serviço pelo ID
  /// Recebe o contexto para mostrar SnackBar com feedback
  void excluirServico(String id, BuildContext context) async {
    await FirebaseFirestore.instance.collection('servicos').doc(id).delete();

    // Mensagem para confirmar que o serviço foi excluído
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Serviço excluído com sucesso!')));
  }

  /// Função que abre um diálogo para editar as informações do serviço
  /// Recebe o contexto e o documento atual do serviço
  void editarServico(BuildContext context, DocumentSnapshot doc) {
    // Controladores inicializados com os dados atuais para edição
    final nomeController = TextEditingController(text: doc['nome']);
    final precoController = TextEditingController(
      text: doc['preco'].toString(),
    );

    // Mostra diálogo modal para edição do serviço
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para editar nome do serviço
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome do Serviço'),
              ),
              // Campo para editar preço, com teclado numérico
              TextField(
                controller: precoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Preço'),
              ),
            ],
          ),
          actions: [
            // Botão para salvar alterações no Firestore
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('servicos')
                    .doc(doc.id)
                    .update({
                      'nome': nomeController.text.trim(),
                      // Tenta converter o preço para double, ou usa 0.0 se inválido
                      'preco':
                          double.tryParse(precoController.text.trim()) ?? 0.0,
                    });

                Navigator.pop(context); // Fecha o diálogo

                // Feedback de sucesso ao usuário
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Serviço atualizado com sucesso!')),
                );
              },
              child: Text('Salvar'),
            ),
            // Botão para cancelar edição
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
      appBar: AppBar(title: Text('Serviços')),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta em tempo real a coleção 'servicos'
        stream: FirebaseFirestore.instance.collection('servicos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          // Caso não tenha serviços cadastrados
          if (docs.isEmpty) {
            return Center(child: Text('Nenhum serviço cadastrado.'));
          }

          // Lista dinâmica de serviços com opções para editar e excluir
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];

              return ListTile(
                title: Text(doc['nome']),
                subtitle: Text('Preço: R\$ ${doc['preco'].toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão para editar serviço
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editarServico(context, doc),
                    ),
                    // Botão para excluir serviço
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => excluirServico(doc.id, context),
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
