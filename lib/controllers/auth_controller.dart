import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Classe responsável por gerenciar a autenticação dos usuários e interações
/// com o Firestore relacionadas ao cadastro e login.
class AuthController {
  // Instância do FirebaseAuth para gerenciar autenticação
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instância do Firestore para manipulação de dados no banco
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método responsável pelo cadastro de um novo usuário.
  /// Recebe o email, senha e tipo de usuário (ex: cliente ou administrador).
  /// Retorna null se o cadastro for bem-sucedido ou a mensagem de erro em caso de falha.
  Future<String?> register(
    String email,
    String password,
    String userType,
  ) async {
    try {
      // Cria o usuário com email e senha no Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Após criar o usuário, salva o tipo no Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'userType': userType,
      });

      return null; // Retorno nulo indica sucesso
    } on FirebaseAuthException catch (e) {
      // Caso ocorra erro durante o cadastro, retorna a mensagem do erro
      return e.message;
    }
  }

  /// Método responsável por autenticar um usuário já cadastrado.
  /// Recebe o email e a senha, e tenta realizar o login.
  /// Retorna null se o login for bem-sucedido ou a mensagem de erro em caso de falha.
  Future<String?> login(String email, String password) async {
    try {
      // Realiza login com email e senha utilizando Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Login realizado com sucesso
    } on FirebaseAuthException catch (e) {
      // Retorna a mensagem de erro caso falhe
      return e.message;
    }
  }

  /// Método responsável por fazer logout do usuário atual.
  Future<void> logout() async {
    // Encerra a sessão do usuário autenticado
    await _auth.signOut();
  }

  /// Método para recuperar o tipo de usuário (por exemplo, "cliente" ou "admin").
  /// Verifica se há um usuário logado e, se houver, consulta o Firestore.
  /// Retorna o tipo do usuário como string ou null se não encontrar.
  Future<String?> getUserType() async {
    // Obtém o usuário atualmente autenticado
    User? user = _auth.currentUser;

    if (user != null) {
      // Consulta o documento do usuário no Firestore
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      // Retorna o tipo de usuário armazenado
      return snapshot['userType'];
    }

    // Retorna null se não houver usuário logado
    return null;
  }
}
