import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Tela que exibe a lista de serviços disponíveis cadastrados no Firestore.
/// A consulta é feita em tempo real com o uso do StreamBuilder.
class ConsultaServicosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar da tela com título e cor personalizada
      appBar: AppBar(
        title: Text('Serviços Disponíveis'),
        backgroundColor: Colors.amber[700],
      ),

      // Corpo da tela: StreamBuilder para escutar mudanças em tempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('servicos').snapshots(),
        builder: (context, snapshot) {
          // Enquanto os dados estão sendo carregados, exibe um indicador de progresso
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Caso não existam dados ou a coleção esteja vazia
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Nenhum serviço cadastrado.'));
          }

          // Lista de documentos da coleção 'servicos'
          final servicos = snapshot.data!.docs;

          // Constrói a lista de serviços em formato de cartões
          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final servico = servicos[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 2, // Sombra do card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // Nome do serviço (em destaque)
                  title: Text(
                    servico['nome'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  // Descrição do serviço
                  subtitle: Text(servico['descricao']),

                  // Preço do serviço formatado
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
