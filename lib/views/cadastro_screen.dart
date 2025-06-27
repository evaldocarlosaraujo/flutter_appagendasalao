import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart'; // Pacote usado para aplicar máscara no telefone
import 'home_cliente.dart';
import 'home_admin.dart';

/// Tela de cadastro de novo usuário (cliente ou administrador).
/// Após o cadastro, o usuário é redirecionado para a tela inicial correspondente.
class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave do formulário para validação

  // Controllers para capturar os dados inseridos nos campos
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  // Valor padrão do tipo de usuário
  String _tipoUsuario = 'cliente';

  // Variável para controlar o estado de carregamento
  bool _carregando = false;

  /// Função responsável por validar e cadastrar o usuário no Firebase Auth e Firestore
  void _cadastrarUsuario() async {
    // Valida os campos do formulário
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true); // Inicia o carregamento

      try {
        // Cria o usuário com email e senha no Firebase Auth
        UserCredential credenciais = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text,
            );

        // Salva os dados adicionais no Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(credenciais.user!.uid)
            .set({
              'nome': _nomeController.text.trim(),
              'email': _emailController.text.trim(),
              'telefone': _telefoneController.text.trim(),
              'tipo': _tipoUsuario,
              'pontos': 0, // Inicia com zero pontos no sistema de fidelidade
              'resgatouBrinde': false, // Indica se já resgatou brinde
            });

        // Redireciona para a tela correspondente ao tipo de usuário
        Widget destino =
            _tipoUsuario == 'administrador' ? HomeAdmin() : HomeCliente();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destino),
        );
      } on FirebaseAuthException catch (e) {
        // Mostra erro em caso de falha na autenticação
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
      } finally {
        setState(() => _carregando = false); // Finaliza o carregamento
      }
    }
  }

  @override
  void dispose() {
    // Libera os recursos dos controllers ao sair da tela
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  /// Monta a interface da tela de cadastro
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
          key: _formKey, // Associa a chave ao formulário
          child: ListView(
            children: [
              // Campo: Nome
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

              // Campo: Email
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

              // Campo: Telefone (com máscara)
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Telefone (com DDD)'),
                inputFormatters: [
                  PhoneInputFormatter(
                    defaultCountryCode: 'BR',
                    allowEndlessPhone: false,
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite seu telefone';
                  }
                  if (value.length < 14) {
                    return 'Telefone incompleto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo: Senha
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

              // Dropdown: Tipo de usuário (por padrão apenas cliente está disponível)
              DropdownButtonFormField<String>(
                value: _tipoUsuario,
                items: [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  // Se quiser ativar o cadastro de administradores, descomente abaixo:
                  // DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoUsuario = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Tipo de usuário'),
              ),
              SizedBox(height: 24),

              // Botão de cadastro com indicador de carregamento
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
