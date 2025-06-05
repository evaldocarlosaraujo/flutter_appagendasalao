import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_cliente.dart';
import 'home_admin.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  String _tipoUsuario = 'cliente'; // valor padrão
  bool _carregando = false;

  void _cadastrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        // Criação do usuário
        UserCredential credenciais = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text,
            );

        // Salvando no Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(credenciais.user!.uid)
            .set({
              'nome': _nomeController.text.trim(),
              'email': _emailController.text.trim(),
              'tipo': _tipoUsuario,
            });

        // Redirecionamento baseado no tipo
        Widget destino =
            _tipoUsuario == 'administrador' ? HomeAdmin() : HomeCliente();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destino),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro'),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome completo'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Digite seu nome'
                            : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value != null && value.contains('@')
                            ? null
                            : 'Email inválido',
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _senhaController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator:
                    (value) =>
                        value != null && value.length >= 6
                            ? null
                            : 'Senha deve ter ao menos 6 caracteres',
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                items: [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  //                 DropdownMenuItem(
                  //                   value: 'administrador',
                  //                   child: Text('Administrador')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoUsuario = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo de usuário'),
              ),
              SizedBox(height: 24),

              _carregando
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _cadastrarUsuario,
                    child: Text('Cadastrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
