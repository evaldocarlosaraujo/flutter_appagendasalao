import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importações das telas acessadas pelo cliente
import 'package:flutter_appagendasalao/views/historico_resgates_screen.dart';
import 'package:flutter_appagendasalao/views/programa_fidelidade_screen.dart';
import 'consulta_servicos_screen.dart';
import 'agendamento_screen.dart';
import 'login_screen.dart';
import 'meus_agendamentos_screen.dart';

/// Tela principal exibida para o cliente após login
class HomeCliente extends StatelessWidget {
  /// Função responsável por fazer logout do usuário e retornar à tela de login
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Redireciona para a tela de login e remove todas as rotas anteriores
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  /// Estilo padrão para os botões desta tela
  ButtonStyle _botaoEstilo() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[700],
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar com título e botão de sair
      appBar: AppBar(
        title: Text('Área do Cliente'),
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
              'Bem-vindo ao App AgendaSalão!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Botão para consultar serviços disponíveis
            ElevatedButton.icon(
              icon: Icon(Icons.design_services),
              label: Text('Ver Serviços e Preços'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ConsultaServicosScreen()),
                );
              },
              style: _botaoEstilo(),
            ),
            SizedBox(height: 10),

            // Botão para realizar um novo agendamento
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_month),
              label: Text('Agendar Horário'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AgendamentoScreen()),
                );
              },
              style: _botaoEstilo(),
            ),
            SizedBox(height: 10),

            // Botão para visualizar os agendamentos realizados
            ElevatedButton.icon(
              icon: Icon(Icons.event_note),
              label: Text('Meus Agendamentos'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MeusAgendamentosScreen()),
                );
              },
              style: _botaoEstilo(),
            ),
            SizedBox(height: 10),

            // Botão para acessar o programa de fidelidade
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProgramaFidelidadeScreen()),
                );
              },
              child: Text('Programa de Fidelidade'),
              style: _botaoEstilo(),
            ),
            SizedBox(height: 10),

            // Botão para ver o histórico de resgates de brindes
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoricoResgatesScreen(),
                  ),
                );
              },
              child: Text('Ver Histórico de Resgates'),
              style: _botaoEstilo(),
            ),
          ],
        ),
      ),
    );
  }
}
