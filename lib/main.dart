// Importações dos pacotes essenciais
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Necessário para iniciar o Firebase
import 'package:flutter_appagendasalao/services/firebase_options.dart'; // Arquivo gerado automaticamente com a configuração do Firebase
import 'views/splash_screen.dart'; // Importa a tela de splash

/// Função principal do app. Ponto de entrada do Flutter.
void main() async {
  // Garante que o Flutter esteja completamente inicializado antes de rodar qualquer código assíncrono
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções específicas da plataforma (Android, iOS, Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicia o app chamando o widget principal (MyApp)
  runApp(MyApp());
}

/// Widget principal da aplicação
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:
          'Agenda Salão', // Título do app (pode aparecer em alguns dispositivos)
      // Tema global do aplicativo
      theme: ThemeData(
        primarySwatch: Colors.amber, // Cor primária usada em AppBar e botões
        scaffoldBackgroundColor:
            Colors.yellow[50], // Cor de fundo padrão das telas
      ),

      home:
          SplashScreen(), // Tela inicial que será exibida (animação de carregamento)
      debugShowCheckedModeBanner:
          false, // Remove o banner "debug" do canto superior direito
    );
  }
}
