import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const HybridFlutterApp());
}

class HybridFlutterApp extends StatelessWidget {
  const HybridFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hybrid Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlutterHomeScreen(),
    );
  }
}

class FlutterHomeScreen extends StatefulWidget {
  const FlutterHomeScreen({super.key});

  @override
  State<FlutterHomeScreen> createState() => _FlutterHomeScreenState();
}

class _FlutterHomeScreenState extends State<FlutterHomeScreen> {
  static const MethodChannel _nativeBridge =
      MethodChannel('com.example.hybrid/native_bridge');

  String _nativeMessage = 'Ожидаем данные от native';

  @override
  void initState() {
    super.initState();
    _loadNativePayload();
  }

  Future<void> _loadNativePayload() async {
    try {
      final message = await _nativeBridge.invokeMethod<String>(
        'getInitialPayload',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _nativeMessage = message ?? 'Native не передал payload';
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _nativeMessage = 'Ошибка MethodChannel: ${error.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter часть')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Теперь приложение работает во Flutter',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Первые экраны были нативными. Flutter engine был прогрет '
                'до перехода, а этот экран открыт через cached engine.',
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payload от native',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(_nativeMessage),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _loadNativePayload,
                child: const Text('Обновить payload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
