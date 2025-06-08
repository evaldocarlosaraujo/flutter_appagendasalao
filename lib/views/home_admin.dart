import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appagendasalao/views/listar_brindes_screen.dart';
import 'package:flutter_appagendasalao/views/listar_profissionais_screen.dart';
import 'package:flutter_appagendasalao/views/listar_servicos_screen.dart';
import 'package:flutter_appagendasalao/views/login_screen.dart';
import 'package:flutter_appagendasalao/views/resgates_admin_screen.dart';
import 'cadastro_profissional_screen.dart';
import 'cadastro_servico_screen.dart';
import 'cadastro_brinde_screen.dart'; // <-- importado aqui
import 'agenda_geral_screen.dart';

class HomeAdmin extends StatelessWidget {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Área do Administrador'),
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            Text(
              'Bem-vindo, você está como Admin!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CadastroProfissionalScreen(),
                  ),
                );
              },
              child: Text('Cadastrar Profissional'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListarProfissionaisScreen(),
                  ),
                );
              },
              child: Text('Gerenciar Profissionais'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroServicoScreen()),
                );
              },
              child: Text('Cadastrar Serviço'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListarServicosScreen()),
                );
              },
              child: Text('Gerenciar Serviços'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AgendaGeralScreen()),
                );
              },
              child: Text('Agenda Geral'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroBrindeScreen()),
                );
              },
              child: Text('Cadastrar Brinde'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ListarBrindesScreen()),
                );
              },
              child: Text('Gerenciar Brindes'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResgatesAdminScreen()),
                );
              },
              child: Text('Resgates de Brindes'),
            ),
          ],
        ),
      ),
    );
  }
}
