import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Importações das telas que o administrador pode acessar
import 'package:flutter_appagendasalao/views/listar_brindes_screen.dart';
import 'package:flutter_appagendasalao/views/listar_profissionais_screen.dart';
import 'package:flutter_appagendasalao/views/listar_servicos_screen.dart';
import 'package:flutter_appagendasalao/views/login_screen.dart';
import 'package:flutter_appagendasalao/views/resgates_admin_screen.dart';
import 'cadastro_profissional_screen.dart';
import 'cadastro_servico_screen.dart';
import 'cadastro_brinde_screen.dart';
import 'agenda_geral_screen.dart';

/// Tela principal para o usuário com perfil de administrador
class HomeAdmin extends StatelessWidget {
  /// Função responsável por fazer o logout do Firebase e redirecionar para a tela de login
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Remove todas as rotas anteriores e redireciona para o login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com botão de logout no canto superior direito
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

      // Corpo principal da tela com os botões de navegação
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          children: [
            // Mensagem de boas-vindas
            Text(
              'Bem-vindo, você está como Admin!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Botão para cadastrar um novo profissional
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

            // Botão para listar e gerenciar profissionais cadastrados
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

            // Botão para cadastrar um novo serviço
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

            // Botão para listar e gerenciar serviços
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

            // Botão para acessar a agenda geral com todos os agendamentos
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

            // Botão para cadastrar brindes que podem ser resgatados com pontos
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

            // Botão para visualizar e editar os brindes cadastrados
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

            // Botão para aprovar ou rejeitar os resgates de brindes feitos pelos clientes
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
