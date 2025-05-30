import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ConsultaServicosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serviços Disponíveis'),
        backgroundColor: Colors.amber[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('servicos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum serviço cadastrado.'));
          }

          final servicos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final servico = servicos[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    servico['nome'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(servico['descricao']),
                  trailing: Text(
                    'R\$ ${servico['preco'].toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
