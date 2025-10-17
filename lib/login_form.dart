import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'unidades_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  Future<void> _login() async {
    String cliente = _clienteController.text;
    String usuario = _usuarioController.text;
    String senha = _senhaController.text;

    String url = 'https://aciersgm.com.br/osp_login.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userdata': '$cliente^$usuario^$senha',
        },
      );
      // Verifique o código de status da resposta do servidor
      if (response.statusCode == 200) {

         print('Resposta: ${response.body}');

        // Verifique se a resposta possui exatamente quatro partes separadas por "^"
        List<String> respostaPartes = response.body.split('^');
        if (respostaPartes.length == 4) {
          // Use a primeira parte como 'cliente'
          String clienteRetornado = respostaPartes[0];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UnidadesPage(
                modulo: clienteRetornado, // Passando o valor de 'cliente'
              ),
            ),
          );
        } else {
          _showErrorDialog(
              'Falha - Usuário não cadastrado no SGM ou senha errada!');
        }

      } else {
        print('Falha no login');
        print('Resposta: ${response.body}');
        _showErrorDialog(
            'Falha - Usuário não cadastrado no SGM ou senha errada!');
      }
    } catch (e) {
      print('Erro: $e');
      _showErrorDialog('Erro: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro de Login'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACIER FC - Login'),
        backgroundColor: const Color.fromARGB(255, 19, 84, 182), // Cor de fundo do AppBar
        foregroundColor: Colors.white, // Cor dos ícones e textos
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _clienteController,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(labelText: 'Usuário'),
                ),
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _senhaController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ACIER FC - Login'),
        backgroundColor: const Color.fromARGB(255, 19, 84, 182), // Cor de fundo do AppBar
        foregroundColor: Colors.white, // Cor dos ícones e textos
      ),
      body: const Center(
        child: Text('Bem-vindo à Home Page!'),
      ),
    );
  }
}
