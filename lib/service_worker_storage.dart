library service_worker_storage;

export 'service_worker_storage.io.dart'
    if (dart.library.html) 'service_worker_storage.web.dart';
