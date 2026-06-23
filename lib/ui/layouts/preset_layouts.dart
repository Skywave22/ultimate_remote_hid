import 'package:flutter/material.dart';
import '../../core/layout_engine.dart';

class PresetLayouts {
  static List<AppComponent> getProKeyboard() {
    List<AppComponent> layout = [];
    List<String> keys = ['Q','W','E','R','T','Y','U','I','O','P'];
    double startX = 0.1;
    double startY = 0.3;
    for (int i = 0; i < keys.length; i++) {
      layout.add(AppComponent(
        id: 'key_${keys[i]}',
        label: keys[i],
        type: ComponentType.button,
        relativePosition: Offset(startX + (i * 0.08), startY),
        relativeSize: Size(0.07, 0.1),
        color: Colors.blue,
        actionValue: keys[i],
      ));
    }
    layout.add(AppComponent(
      id: 'key_space',
      label: 'SPACE',
      type: ComponentType.button,
      relativePosition: Offset(0.3, 0.6),
      relativeSize: Size(0.4, 0.1),
      color: Colors.blue,
      actionValue: 'SPACE',
    ));
    return layout;
  }

  static List<AppComponent> getGamepad() {
    return [
      AppComponent(id: 'l_stick', label: 'L', type: ComponentType.joystick, relativePosition: Offset(0.1, 0.4), relativeSize: Size(0.2, 0.2), color: Colors.blueAccent, actionValue: 'L_STICK'),
      AppComponent(id: 'btn_a', label: 'A', type: ComponentType.button, relativePosition: Offset(0.85, 0.6), relativeSize: Size(0.08, 0.08), color: Colors.green, actionValue: 'A'),
      AppComponent(id: 'btn_b', label: 'B', type: ComponentType.button, relativePosition: Offset(0.95, 0.5), relativeSize: Size(0.08, 0.08), color: Colors.red, actionValue: 'B'),
    ];
  }
}
