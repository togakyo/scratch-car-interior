import 'dart:js_interop';

@JS('ScratchCarAudio.scratch')
external void _scratch();
@JS('ScratchCarAudio.reveal')
external void _reveal();
@JS('ScratchCarAudio.horn')
external void _horn();
@JS('ScratchCarAudio.lights')
external void _lights();
@JS('ScratchCarAudio.wash')
external void _wash();
@JS('ScratchCarAudio.party')
external void _party();
@JS('ScratchCarAudio.spin')
external void _spin();
@JS('ScratchCarAudio.color')
external void _color();
@JS('ScratchCarAudio.start')
external void _start();

class SoundManager {
  static void scratch() { try { _scratch(); } catch (_) {} }
  static void reveal()  { try { _reveal();  } catch (_) {} }
  static void horn()    { try { _horn();    } catch (_) {} }
  static void lights()  { try { _lights();  } catch (_) {} }
  static void wash()    { try { _wash();    } catch (_) {} }
  static void party()   { try { _party();   } catch (_) {} }
  static void spin()    { try { _spin();    } catch (_) {} }
  static void color()   { try { _color();   } catch (_) {} }
  static void start()   { try { _start();   } catch (_) {} }
}
