import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListarProfissionaisScreen extends StatelessWidget {
  void excluirProfissional(String id, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('profissionais')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profissional excluído com sucesso!')),
    );
  }

  void editarProfissional(BuildContext context, DocumentSnapshot doc) {
    final nomeController = TextEditingController(text: doc['nome']);
    final especialidadeController = TextEditingController(
      text: doc['especialidade'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Profissional'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: especialidadeController,
                decoration: InputDecoration(labelText: 'Especialidade'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('profissionais')
                    .doc(doc.id)
                    .update({
                      'nome': nomeController.text.trim(),
                      'especialidade': especialidadeController.text.trim(),
                    });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profissional atualizado com sucesso!'),
                  ),
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
      appBar: AppBar(title: Text('Profissionais')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('profissionais').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(child: Text('Nenhum profissional cadastrado.'));
          }

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
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => editarProfissional(context, doc),
                    ),
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
