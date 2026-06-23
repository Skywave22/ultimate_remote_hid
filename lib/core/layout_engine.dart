import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ComponentType { button, touchpad, joystick, slider, scanner }

class AppComponent {
  String id;
  String label;
  ComponentType type;
  Offset relativePosition;
  Size relativeSize;
  Color color;
  String actionValue; 
  
  AppComponent({
    required this.id,
    required this.label,
    required this.type,
    required this.relativePosition,
    required this.relativeSize,
    required this.color,
    required this.actionValue,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'type': type.index,
    'relPosX': relativePosition.dx,
    'relPosY': relativePosition.dy,
    'relWidth': relativeSize.width,
    'relHeight': relativeSize.height,
    'color': color.value,
    'action': actionValue,
  };

  factory AppComponent.fromJson(Map<String, dynamic> json) => AppComponent(
    id: json['id'],
    label: json['label'],
    type: ComponentType.values[json['type']],
    relativePosition: Offset(json['relPosX'], json['relPosY']),
    relativeSize: Size(json['relWidth'], json['relHeight']),
    color: Color(json['color']),
    actionValue: json['action'],
  );
}

class LayoutState {
  final List<AppComponent> components;
  final Color themePrimaryColor;
  final bool isEditMode;

  LayoutState({
    required this.components,
    required this.themePrimaryColor,
    this.isEditMode = false,
  });

  LayoutState copyWith({List<AppComponent>? components, Color? themePrimaryColor, bool? isEditMode}) {
    return LayoutState(
      components: components ?? this.components,
      themePrimaryColor: themePrimaryColor ?? this.themePrimaryColor,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }
}

final layoutProvider = StateNotifierProvider<LayoutNotifier, LayoutState>((ref) {
  return LayoutNotifier();
});

class LayoutNotifier extends StateNotifier<LayoutState> {
  LayoutNotifier() : super(LayoutState(
    components: _generateDefaultLayout(), 
    themePrimaryColor: Color(0xFF2196F3),
  ));

  static List<AppComponent> _generateDefaultLayout() {
    return [
      AppComponent(
        id: 'touchpad_1', 
        label: 'Touchpad', 
        type: ComponentType.touchpad, 
        relativePosition: Offset(0.05, 0.2), 
        relativeSize: Size(0.5, 0.6), 
        color: Colors.blueAccent.withOpacity(0.3), 
        actionValue: 'MOUSE_MOVE'
      ),
      AppComponent(
        id: 'btn_enter', 
        label: 'ENTER', 
        type: ComponentType.button, 
        relativePosition: Offset(0.6, 0.2), 
        relativeSize: Size(0.15, 0.15), 
        color: Colors.blue, 
        actionValue: 'ENTER'
      ),
    ];
  }

  void toggleEditMode() => state = state.copyWith(isEditMode: !state.isEditMode);
  
  void updateComponentPosition(String id, Offset delta, Size screenSize) {
    final updated = state.components.map((c) {
      if (c.id == id) {
        double newX = c.relativePosition.dx + (delta.dx / screenSize.width);
        double newY = c.relativePosition.dy + (delta.dy / screenSize.height);
        return ...c, relativePosition: Offset(newX.clamp(0.0, 1.0), newY.clamp(0.0, 1.0));
      }
      return c;
    }).toList();
    state = state.copyWith(components: updated);
  }

  void updateComponentProperty(String id, Map<String, dynamic> updates) {
    final updated = state.components.map((c) {
      if (c.id == id) {
        return AppComponent(
          id: c.id,
          label: updates['label'] ?? c.label,
          type: c.type,
          relativePosition: c.relativePosition,
          relativeSize: updates['size'] ?? c.relativeSize,
          color: updates['color'] ?? c.color,
          actionValue: updates['action'] ?? c.actionValue,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(components: updated);
  }

  void addComponent(ComponentType type) {
    final newComp = AppComponent(
      id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
      label: 'New ${type.name}',
      type: type,
      relativePosition: Offset(0.5, 0.5),
      relativeSize: Size(0.1, 0.1),
      color: state.themePrimaryColor,
      actionValue: 'KEY_A',
    );
    state = state.copyWith(components: [...state.components, newComp]);
  }

  void removeComponent(String id) {
    state = state.copyWith(components: state.components.where((c) => c.id != id).toList());
  }
  
  void updateThemeColor(Color newColor) => state = state.copyWith(themePrimaryColor: newColor);
}
