import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListarBrindesScreen extends StatefulWidget {
  @override
  State<ListarBrindesScreen> createState() => _ListarBrindesScreenState();
}

class _ListarBrindesScreenState extends State<ListarBrindesScreen> {
  final CollectionReference brindesRef = FirebaseFirestore.instance.collection(
    'brindes',
  );

  void excluirBrinde(String id) async {
    await brindesRef.doc(id).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Brinde excluído com sucesso.')));
  }

  void editarBrinde(String id, String nomeAtual, String descricaoAtual) {
    TextEditingController nomeController = TextEditingController(
      text: nomeAtual,
    );
    TextEditingController descricaoController = TextEditingController(
      text: descricaoAtual,
    );

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
                  await brindesRef.doc(id).update({
                    'nome': nomeController.text,
                    'descricao': descricaoController.text,
                  });
                  Navigator.pop(context);
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
        stream: brindesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final brindes = snapshot.data!.docs;

          if (brindes.isEmpty) {
            return Center(child: Text('Nenhum brinde cadastrado.'));
          }

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
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => editarBrinde(
                            brinde.id,
                            brinde['nome'],
                            brinde['descricao'],
                          ),
                    ),
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
