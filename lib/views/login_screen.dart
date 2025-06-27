import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'home_cliente.dart';
import 'home_admin.dart';
import 'cadastro_screen.dart';

/// Tela de login e cadastro do usuário
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar os dados digitados
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Controla se a tela está no modo login (true) ou cadastro (false)
  bool _isLogin = true;

  // Controla o estado de carregamento para mostrar indicador durante autenticação
  bool _isLoading = false;

  /// Salva o token do Firebase Cloud Messaging (FCM) do usuário no Firestore
  /// para possibilitar envio de notificações push
  Future<void> salvarTokenDoUsuario(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Atualiza o documento do usuário com o token, usando merge para não sobrescrever outros dados
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Erro ao salvar token FCM: $e');
    }
  }

  /// Função que autentica o usuário (login ou cadastro)
  void _autenticarUsuario() async {
    setState(() => _isLoading = true); // Inicia o indicador de carregamento

    try {
      if (_isLogin) {
        // LOGIN do usuário com email e senha
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        final uid = userCredential.user!.uid;

        // Salva o token do FCM para notificações
        await salvarTokenDoUsuario(uid);

        // Consulta dados do usuário no Firestore para identificar tipo (cliente ou administrador)
        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();

        if (doc.exists) {
          final tipo = doc['tipo'];

          // Redireciona para tela adequada conforme tipo do usuário
          if (tipo == 'administrador') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeAdmin()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeCliente()),
            );
          }
        } else {
          // Usuário não encontrado no banco Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário não encontrado no banco de dados.'),
            ),
          );
        }
      } else {
        // Caso esteja no modo cadastro, direciona para tela de cadastro
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CadastroScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Captura erros de autenticação (ex: senha errada, usuário não existe)
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
    } finally {
      setState(() => _isLoading = false); // Termina indicador de carregamento
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50], // Fundo claro amarelo
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo do aplicativo
              Image.asset('assets/img/logo.jpg', height: 360),
              SizedBox(height: 24),

              // Título dinâmico que muda conforme modo (Entrar ou Cadastrar)
              Text(
                _isLogin ? 'Entrar' : 'Cadastrar',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Campo para inserir email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Campo para inserir senha (texto oculto)
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              // Botão para realizar ação de login ou cadastro
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _autenticarUsuario,
                    child: Text(_isLogin ? 'Entrar' : 'Cadastrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      minimumSize: Size(
                        double.infinity,
                        48,
                      ), // Botão grande horizontalmente
                    ),
                  ),
              SizedBox(height: 12),

              // Texto para alternar entre login e cadastro
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin =
                        !_isLogin; // Alterna o estado entre login e cadastro
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Não tem conta? Cadastre-se'
                      : 'Já tem conta? Faça login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
