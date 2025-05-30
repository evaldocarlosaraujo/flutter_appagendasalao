// lib/firebase_messaging.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    // Solicita permissão para receber notificações (necessário em iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão concedida para notificações.');

      // Escuta notificações recebidas em primeiro plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          final title = message.notification!.title ?? 'Nova notificação';
          final body = message.notification!.body ?? '';

          // Exibe um snackbar com a mensagem
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title\n$body'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      });

      // (Opcional) Escuta quando o app é aberto pela notificação
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Usuário clicou na notificação');
        // Você pode redirecionar para uma tela específica, se quiser
      });
    } else {
      print('Permissão para notificações negada.');
    }
  }
}
