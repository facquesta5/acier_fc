import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class NoRoteiroPage extends StatefulWidget {
  const NoRoteiroPage({super.key});

  @override
  _NoRoteiroPageState createState() => _NoRoteiroPageState();
}

class _NoRoteiroPageState extends State<NoRoteiroPage> {
  String _scanResult = 'Nenhum código escaneado';

  Future<void> _scanBarcode() async {
    try {
      final scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Cor do botão de cancelar
        'Cancelar', // Texto do botão de cancelar
        true, // Mostrar flash
        ScanMode.BARCODE, // Modo de escaneamento
      );

      if (!mounted) return;

      setState(() {
        _scanResult = scanResult != '-1' ? scanResult : 'Nenhum código escaneado';
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Falha ao escanear o código: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código de Barras'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Resultado do Escaneamento:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              _scanResult,
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Escanear Código de Barras'),
            ),
          ],
        ),
      ),
    );
  }
}