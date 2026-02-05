import 'server.dart';

void main() async {
  final server = Server(port: 8000, host: '0.0.0.0');
  
  // Handle shutdown gracefully
  ProcessSignal.sigint.watch().listen((signal) {
    print('\n🛑 Received shutdown signal');
    server.stop();
    exit(0);
  });
  
  await server.start();
}
