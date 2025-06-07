import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_appagendasalao/views/programa_fidelidade_screen.dart';
import 'consulta_servicos_screen.dart';
import 'agendamento_screen.dart';
import 'login_screen.dart';
import 'meus_agendamentos_screen.dart';

class HomeCliente extends StatelessWidget {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo ao App AgendaSalão!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

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
            SizedBox(height: 16),

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
            SizedBox(height: 16),

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
            SizedBox(height: 16),

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
          ],
        ),
      ),
    );
  }

  ButtonStyle _botaoEstilo() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.amber[700],
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
