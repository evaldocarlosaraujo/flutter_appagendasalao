import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminResgatesScreen extends StatelessWidget {
  void aprovarResgate(BuildContext context, DocumentSnapshot doc) async {
    await FirebaseFirestore.instance.collection('resgates').doc(doc.id).update({
      'status': 'aprovado',
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Resgate aprovado!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resgates Pendentes')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('resgates')
                .where('status', isEqualTo: 'pendente')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          if (docs.isEmpty)
            return Center(child: Text('Nenhum resgate pendente.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return ListTile(
                title: Text('Cliente ID: ${doc['clienteId']}'),
                subtitle: Text('Data: ${doc['data'].toDate().toString()}'),
                trailing: ElevatedButton(
                  child: Text('Aprovar'),
                  onPressed: () => aprovarResgate(context, doc),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
