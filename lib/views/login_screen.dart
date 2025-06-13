import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'home_cliente.dart';
import 'home_admin.dart';
import 'cadastro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  // 🔐 Salvar token do FCM
  Future<void> salvarTokenDoUsuario(String uid) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Erro ao salvar token FCM: $e');
    }
  }

  void _autenticarUsuario() async {
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // LOGIN
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        final uid = userCredential.user!.uid;
        await salvarTokenDoUsuario(uid);

        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();

        if (doc.exists) {
          final tipo = doc['tipo'];
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Usuário não encontrado no banco de dados.'),
            ),
          );
        }
      } else {
        // CADASTRO
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CadastroScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/img/logo.jpg', height: 360),
              SizedBox(height: 24),
              Text(
                _isLogin ? 'Entrar' : 'Cadastrar',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _autenticarUsuario,
                    child: Text(_isLogin ? 'Entrar' : 'Cadastrar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 48),
                    ),
                  ),
              SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
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
