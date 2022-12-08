library service_worker_storage;

export 'src/service_worker_storage.io.dart'
    if (dart.library.html) 'src/service_worker_storage.web.dart';
