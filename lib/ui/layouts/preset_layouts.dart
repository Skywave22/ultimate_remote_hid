import 'package:flutter/material.dart';
import '../../core/layout_engine.dart';

class PresetLayouts {
  static List<AppComponent> getProKeyboard() {
    List<AppComponent> layout = [];
    List<String> keys = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    double startX = 0.05;
    double startY = 0.3;
    for (int i = 0; i < keys.length; i++) {
      layout.add(AppComponent(
        id: 'key_${keys[i]}',
        label: keys[i],
        type: ComponentType.button,
        relativePosition: Offset(startX + (i * 0.09), startY),
        relativeSize: const Size(0.08, 0.1),
        color: Colors.blue,
        actionValue: keys[i],
      ));
    }
    layout.add(AppComponent(
      id: 'key_space',
      label: 'SPACE',
      type: ComponentType.button,
      relativePosition: const Offset(0.3, 0.5),
      relativeSize: const Size(0.4, 0.1),
      color: Colors.blue,
      actionValue: 'SPACE',
    ));
    return layout;
  }

  static List<AppComponent> getGamepad() {
    return [
      AppComponent(
        id: 'l_stick',
        label: 'L',
        type: ComponentType.joystick,
        relativePosition: const Offset(0.1, 0.4),
        relativeSize: const Size(0.2, 0.2),
        color: Colors.blueAccent,
        actionValue: 'L_STICK',
      ),
      AppComponent(
        id: 'btn_a',
        label: 'A',
        type: ComponentType.button,
        relativePosition: const Offset(0.8, 0.6),
        relativeSize: const Size(0.1, 0.1),
        color: Colors.green,
        actionValue: 'A',
      ),
      AppComponent(
        id: 'btn_b',
        label: 'B',
        type: ComponentType.button,
        relativePosition: const Offset(0.9, 0.5),
        relativeSize: const Size(0.1, 0.1),
        color: Colors.red,
        actionValue: 'B',
      ),
    ];
  }
}
