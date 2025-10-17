import 'package:flutter/material.dart';
import 'salas_page.dart';
import 'package:http/http.dart' as http;

class UnidadesPage extends StatefulWidget {
  final String modulo; // Recebe o nome do módulo (cliente)
  const UnidadesPage({super.key, required this.modulo});

  @override
  State<UnidadesPage> createState() => _UnidadesPageState();
}

class _UnidadesPageState extends State<UnidadesPage> {
  List<Map<String, String>> unidades = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _carregarUnidades();
  }

  Future<void> _carregarUnidades() async {
    try {
      final url = Uri.parse('https://aciersgm.com.br/fc1.php?modulo=${widget.modulo}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        String body = response.body.trim();
        if (body.isNotEmpty) {
          // Exemplo de retorno: "1,LMB;2,CF;3,PB;"
          List<String> partes = body.split(';');
          List<Map<String, String>> temp = [];

          for (var p in partes) {
            if (p.contains(',')) {
              var partes2 = p.split(',');
              temp.add({
                'id': partes2[0],
                'sigla': partes2[1],
              });
            }
          }

          setState(() {
            unidades = temp;
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
        title: Text('Unidades - ${widget.modulo}'),
        backgroundColor: const Color.fromARGB(255, 19, 84, 182),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(
                  child: Text(
                    'Erro ao carregar unidades.',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: unidades.length,
                  itemBuilder: (context, index) {
                    final unidade = unidades[index];
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
                              builder: (context) => SalasPage(
                                modulo: widget.modulo,
                                unidadeId: unidade['id'] ?? '',
                                unidadeSigla: unidade['sigla'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Text(unidade['sigla'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
