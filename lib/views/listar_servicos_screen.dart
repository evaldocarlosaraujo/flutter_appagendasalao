import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListarServicosScreen extends StatelessWidget {
  void excluirServico(String id, BuildContext context) async {
    await FirebaseFirestore.instance.collection('servicos').doc(id).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Serviço excluído com sucesso!')));
  }

  void editarServico(BuildContext context, DocumentSnapshot doc) {
    final nomeController = TextEditingController(text: doc['nome']);
    final precoController = TextEditingController(
      text: doc['preco'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Serviço'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome do Serviço'),
              ),
              TextField(
                controller: precoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Preço'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('servicos')
                    .doc(doc.id)
                    .update({
                      'nome': nomeController.text.trim(),
                      'preco':
                          double.tryParse(precoController.text.trim()) ?? 0.0,
                    });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Serviço atualizado com sucesso!')),
                );
              },
              child: Text('Salvar'),
            ),
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
        stream: FirebaseFirestore.instance.collection('servicos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('Nenhum serviço cadastrado.'));
          }

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
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editarServico(context, doc),
                    ),
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
