// Importa os pacotes necessários
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Pacote para animações em JSON (Lottie)
import 'login_screen.dart'; // Tela que será aberta após o splash

/// Tela de splash que exibe uma animação por alguns segundos antes de navegar para a tela de login.
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Aguarda 3 segundos e depois redireciona o usuário para a tela de login
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corpo centralizado com animação Lottie
      body: Center(
        child: Lottie.asset(
          'assets/splash.json', // Caminho da animação (arquivo JSON na pasta assets)
        ),
      ),
    );
  }
}
