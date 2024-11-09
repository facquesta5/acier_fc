import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class NoRoteiroPage extends StatefulWidget {
  final String cliente;

  const NoRoteiroPage({super.key, required this.cliente});

  @override
  _NoRoteiroPageState createState() => _NoRoteiroPageState();
}

class _NoRoteiroPageState extends State<NoRoteiroPage> {
  String _scanResult = '';

  Future<void> _scanBarcodee() async {

    try {
      // Escaneia o código
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Cor do botão de cancelar
        'Cancelar', // Texto do botão de cancelar
        true, // Mostrar flash
        ScanMode.BARCODE, // Modo de escaneamento
      );

      // Verifica se o código foi escaneado corretamente
      if (scanResult == '-1') return; // '-1' indica cancelamento
      
      // Prepara a URL e parâmetros reais
      String url = 'https://aciersgm.com.br/qr_prontuario.php';   // qr_prontuario.php?qrcode=parametros
      String parametros = '$scanResult';

      // Envia o código e o nome do cliente para a URL
      final response = await http.post(
        Uri.parse(url),
        body: {
          'qrcode': parametros,
        },
      );

      // Exibe o resultado da requisição
      setState(() {
        _scanResult = response.statusCode == 200
            ? response.body
            : 'Erro na requisição: ${response.statusCode}';
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Erro na requisição: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Separar os dados de retorno usando o caractere "^"
    List<String> dados = _scanResult.split('^');

    // Extrair o tipo e o código do equipamento
    String tipoEquipamento = dados.isNotEmpty ? dados[0] : 'Desconhecido';
    String codigoEquipamento = dados.length > 1 ? dados[1] : 'Desconhecido';

    // Remover os dois primeiros elementos para deixar só as ordens de serviço
    List<String> ordensServico = dados.length > 2 ? dados.sublist(2) : [];

    // Variáveis para armazenar as ordens de serviço organizadas
    List<Map<String, String>> ordens = [];
    Map<String, String> ordemAtual = {};

    for (int i = 0; i < ordensServico.length; i++) {
      String item = ordensServico[i];

      // Verifica se o item é um novo tipo de ordem de serviço
      if (item == 'OSP' || item == 'OSC' || item == 'OSCS') {
        // Salva a ordem atual no array, se ela não estiver vazia
        if (ordemAtual.isNotEmpty) {
          ordens.add(ordemAtual);
          ordemAtual = {}; // Reseta para a próxima ordem
        }

        // Inicia uma nova ordem com o tipo atual
        ordemAtual['Tipo'] = item;
        ordemAtual['Número'] = ordensServico[i + 1];
        ordemAtual['Data de emissão/abertura'] = ordensServico[i + 2];

        if (item == 'OSC' || item == 'OSCS') {
          // Regra específica para OSC
          ordemAtual['Observação'] = ordensServico[i + 3];
          ordemAtual['Status'] = ordensServico[i + 4];
          ordemAtual['Data da conclusão'] = ordensServico[i + 5];

          // Pula os próximos 5 elementos pois já foram processados
          i += 5;
        } else {
          // Regra padrão para outros tipos
          ordemAtual['Status'] = ordensServico[i + 3];
          ordemAtual['Data da conclusão'] = ordensServico[i + 4];
          ordemAtual['Quem executou'] = ordensServico[i + 5];

          // Pula os próximos 5 elementos pois já foram processados
          i += 5;
        }
      }
    }

    // Adiciona a última ordem ao array
    if (ordemAtual.isNotEmpty) {
      ordens.add(ordemAtual);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear'),
        automaticallyImplyLeading: false, // Remove o botão de voltar padrão
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Ícone de seta para o lado esquerdo
          onPressed: () {
            // Redireciona para a própria página com o botão "Escanear Equipamento"
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NoRoteiroPage(cliente: widget.cliente)),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_scanResult.isNotEmpty) ...[
                Text(
                  'Equipamento: $tipoEquipamento',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'Código do Equipamento: $codigoEquipamento',
                  style: const TextStyle(fontSize: 18),
                ),                
                const SizedBox(height: 10),
                ...ordens.map((ordem) {
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ordem['Tipo']}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Número: ${ordem['Número']}'),
                          Text(
                              'Data de emissão/abertura: ${ordem['Data de emissão/abertura']}'),
                          if (ordem['Tipo'] == 'OSC' || ordem['Tipo'] == 'OSCS') ...[
                            Text('Observação: ${ordem['Observação']}'),
                            Text('Status: ${ordem['Status']}'),
                            Text(
                                'Data da conclusão: ${ordem['Data da conclusão']}'),
                          ] else ...[
                            Text('Status: ${ordem['Status']}'),
                            Text(
                                'Data da conclusão: ${ordem['Data da conclusão']}'),
                            Text('Quem executou: ${ordem['Quem executou']}'),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _scanBarcodee,
                child: const Text('Escanear Equipamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
