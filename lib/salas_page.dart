import 'package:flutter/material.dart';
import 'equipamento_page.dart';
import 'package:http/http.dart' as http;

class SalasPage extends StatefulWidget {
  final String modulo;
  final String unidadeId;
  final String unidadeSigla;

  const SalasPage({
    super.key,
    required this.modulo,
    required this.unidadeId,
    required this.unidadeSigla,
  });

  @override
  State<SalasPage> createState() => _SalasPageState();
}

class _SalasPageState extends State<SalasPage> {
  List<Map<String, String>> salas = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarSalas();
  }

  Future<void> _carregarSalas() async {
    try {
      final url = Uri.parse(
          'https://aciersgm.com.br/fc2.php?modulo=${widget.modulo}&unidade=${widget.unidadeId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        String body = response.body.trim();
        print('Retorno fc2: $body'); // para depuração

        if (body.isNotEmpty) {
          // Exemplo de retorno: "fc1,localizacao;fc2,localizacao;fcn3,localizacao;"
          List<String> partes = body.split(';');
          List<Map<String, String>> temp = [];

          for (var p in partes) {
            if (p.contains(',')) {
              var partes2 = p.split(',');
              if (partes2.length >= 2) {
                temp.add({
                  'codigo': partes2[0].trim(),
                  'nome': partes2[1].trim(),
                });
              }
            }
          }

          setState(() {
            salas = temp;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar salas: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Salas - ${widget.unidadeSigla.toUpperCase()} (${widget.modulo})'),
        backgroundColor: const Color.fromARGB(255, 19, 84, 182),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text(
                    'Erro ao carregar salas.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: salas.length,
                  itemBuilder: (context, index) {
                    final sala = salas[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor:
                              const Color.fromARGB(255, 19, 84, 182),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EquipamentoPage(
                                modulo: widget.modulo,
                                equip: sala['codigo'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Text(sala['nome'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
