import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EquipamentoPage extends StatefulWidget {
  final String modulo;
  final String equip;

  const EquipamentoPage({
    super.key,
    required this.modulo,
    required this.equip,
  });

  @override
  State<EquipamentoPage> createState() => _EquipamentoPageState();
}

class _EquipamentoPageState extends State<EquipamentoPage> {
  bool carregando = true;
  String erro = '';

  double tempSetup = 0;
  double tempAmb = 0;
  bool onOff = false;
  bool ventClima = false;
  bool func = false;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final url = Uri.parse(
        'https://aciersgm.com.br/fc3.php?modulo=${widget.modulo}&equip=${widget.equip}');

    try {
      final resposta = await http.get(url);
      if (resposta.statusCode == 200) {
        final body = resposta.body.trim();
        final partes = body.split(',');
        Map<String, String> dados = {};
        for (var p in partes) {
          if (p.contains('=')) {
            final kv = p.split('=');
            if (kv.length == 2) {
              dados[kv[0]] = kv[1];
            }
          }
        }

        setState(() {
          tempSetup = double.tryParse(dados['TempSetup'] ?? '0') ?? 0;
          tempAmb = double.tryParse(dados['TempAmb'] ?? '0') ?? 0;
          onOff = (dados['onoff'] == '1');
          ventClima = (dados['vent_clima'] == '1');
          func = (dados['func'] == '1');
          carregando = false;
        });
      } else {
        setState(() {
          erro = 'Erro: ${resposta.statusCode}';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao conectar: $e';
        carregando = false;
      });
    }
  }

  // 🔹 Envia atualização para o servidor reativamente
  Future<void> enviarAtualizacao(String parametro, dynamic valor) async {
    final url = Uri.parse(
        'https://aciersgm.com.br/fc4.php?modulo=${widget.modulo}&equip=${widget.equip}&$parametro=$valor');
    try {
      await http.get(url);
    } catch (_) {
      // falha silenciosa
    }
  }

  Widget _buildControlIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.grey.shade600, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    // Define se o sistema está realmente em falha/parado
    final bool parado = !onOff || !func;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: parado ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: parado ? Colors.red : Colors.green, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: parado ? Colors.red : Colors.green, size: 10),
          const SizedBox(width: 8),
          Text(
            parado ? 'Desligado / Falha' : 'Em Operação',
            style: TextStyle(
              color: parado ? Colors.red.shade700 : Colors.green.shade700,
              fontSize: 14,
              letterSpacing: 0.5,
              shadows: parado
                  ? [const Shadow(offset: Offset(0.5, 0.5), blurRadius: 1, color: Colors.redAccent)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempAmbIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Ambiente: ${tempAmb.toStringAsFixed(1)}°C',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Controle ${widget.equip}'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro.isNotEmpty
              ? Center(child: Text(erro))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        '${tempSetup.toStringAsFixed(0)}°C',
                        style: TextStyle(
                          fontSize: 96,
                          fontWeight: FontWeight.w200,
                          color:
                              onOff ? Colors.blueAccent.shade700 : Colors.grey,
                        ),
                      ),
                      const Text(
                        'Setup',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Slider(
                        value: tempSetup,
                        min: 14,
                        max: 28,
                        divisions: 28 - 14,
                        label: '${tempSetup.toStringAsFixed(0)}°C',
                        activeColor: Colors.blueAccent,
                        inactiveColor: Colors.blueAccent.withOpacity(0.4),
                        onChanged: onOff
                            ? (valor) {
                                setState(() {
                                  tempSetup = valor;
                                });
                                enviarAtualizacao('TempSetup',
                                    tempSetup.toStringAsFixed(1));
                              }
                            : null,
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusIndicator(),
                          _buildTempAmbIndicator(),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Botões reposicionados logo abaixo dos indicadores
                      Row(
                        children: [
                          Expanded(
                            child: _buildControlIcon(
                              icon: onOff
                                  ? Icons.power_settings_new
                                  : Icons.power_off,
                              label: onOff ? 'LIGADO' : 'DESLIGADO',
                              isActive: onOff,
                              activeColor:
                                  onOff ? Colors.green : Colors.grey.shade600,
                              onTap: () {
                                setState(() {
                                  onOff = !onOff;
                                });
                                enviarAtualizacao(
                                    'onoff', onOff ? '1' : '0');
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildControlIcon(
                              icon: ventClima
                                  ? FontAwesomeIcons.snowflake
                                  : FontAwesomeIcons.fan,
                              label: ventClima ? 'CLIMA' : 'VENTILAÇÃO',
                              isActive: ventClima,
                              activeColor: ventClima
                                  ? Colors.blueAccent
                                  : Colors.orange,
                              onTap: () {
                                if (onOff) {
                                  setState(() {
                                    ventClima = !ventClima;
                                  });
                                  enviarAtualizacao(
                                      'vent_clima', ventClima ? '1' : '0');
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
    );
  }
}
