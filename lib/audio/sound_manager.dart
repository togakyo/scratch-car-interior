// Conditional export: web version uses dart:js_interop; stub for others.
export 'sound_manager_stub.dart'
    if (dart.library.js_interop) 'sound_manager_web.dart';
