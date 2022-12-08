import 'dart:async';
import 'dart:html';

// final serviceWorkerContainer = window.navigator.serviceWorker;
// serviceWorkerContainer?.register('sw_jwt.js');

class ServiceWorkerStorage {
  ServiceWorker? _worker;

  Future<void> init() async {
    final workersInstalled =
        await window.navigator.serviceWorker?.getRegistrations();

    _worker = (workersInstalled?[0] as ServiceWorkerRegistration?)?.active;
  }

  Future<Map<dynamic, dynamic>> read() async {
    final streamController = StreamController<Map<dynamic, dynamic>>();

    window.navigator.serviceWorker?.addEventListener("message", (event) {
      final messageEvent = event as MessageEvent;

      streamController.add(messageEvent.data);
    });

    return streamController.stream.first.timeout(const Duration(seconds: 1),
        onTimeout: () => throw Exception("can't read service worker"));
  }

  void write(Map<dynamic, dynamic> data) => _worker?.postMessage(data);

  Future<void> writeFull(Map<dynamic, dynamic> data) async {
    ServiceWorker? worker;

    final workersInstalled =
        await window.navigator.serviceWorker?.getRegistrations();

    worker = (workersInstalled?[0] as ServiceWorkerRegistration?)?.active;

    worker?.postMessage(data);
  }
}
