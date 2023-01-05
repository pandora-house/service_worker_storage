## Service worker storage

Implement for store data in flutter web projects when browser reload page

## Usage example

Create file `service_worker_storage.js` and paste to `web` folder.

```js
// These listeners will make the service worker immediately available for the page
self.addEventListener('install', function(event) {
    event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', function(event) {
    event.waitUntil(self.clients.claim());
});

// Global variable in the service worker
let data = 'init data from service worker storage';

// Exposed "method" for saving the data
self.addEventListener('message', function(event) {
    if (event.data && event.data.type === 'SET_DATA') {
        data = event.data.data;
    }
    if (event.data && event.data.type === 'CLEAR_DATA') {
        data = '';
    }
    if (event.data && event.data.type === 'GET_DATA') {
        event.source.postMessage({'data': data});
    }
})
```

Load service worker inside `index.html`
```html
<head>
  <script>
    if ('serviceWorker' in navigator) {
      window.addEventListener('load', function () {
        navigator.serviceWorker.register('service_worker_storage.js', {scope: 'index.html'}).then(function (registration) {
          console.log('ServiceWorker registration successful!')
        }, function (err) {
          console.log('ServiceWorker registration failed: ', err);
        });
      });
    }
  </script>
</head>
```

Do whatever you want to do
```dart
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:service_worker_storage/service_worker_storage.dart';

void main() async {
  final worker = ServiceWorkerStorage();

  await worker.init();

  worker.write({'type': 'GET_DATA'});

  runApp(MyApp(serviceWorkerStorage: worker));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.serviceWorkerStorage});

  final ServiceWorkerStorage serviceWorkerStorage;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _data = '';

  @override
  void initState() {
    super.initState();

    try {
      _read();
    } catch (_) {}
  }

  void _read() async {
    final data = await widget.serviceWorkerStorage.read();


    if (data['data']?.isEmpty ?? true) return;

    setState(() {
      _data = data['data']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_data),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  onPressed: () {
                    widget.serviceWorkerStorage
                        .write({'type': 'SET_DATA', 'data': 'test data'});
                  },
                  child: const Text('WRITE DATA')),
            ],
          ),
        ),
      ),
    );
  }
}
```