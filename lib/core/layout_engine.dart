import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ComponentType { button, touchpad, joystick, slider, scanner }

class AppComponent {
  final String id; final String label; final ComponentType type; final Offset relativePosition; final Size relativeSize; final Color color; final String actionValue; 
  AppComponent({required this.id, required this.label, required this.type, required this.relativePosition, required this.relativeSize, required this.color, required this.actionValue});
  AppComponent copyWith({String? label, Offset? relativePosition, Size? relativeSize, Color? color, String? actionValue}) {
    return AppComponent(id: this.id, label: label ?? this.label, type: this.type, relativePosition: relativePosition ?? this.relativePosition, relativeSize: relativeSize ?? this.relativeSize, color: color ?? this.color, actionValue: actionValue ?? this.actionValue);
  }
}

class LayoutState {
  final List<AppComponent> components; final Color themePrimaryColor; final bool isEditMode;
  LayoutState({required this.components, required this.themePrimaryColor, this.isEditMode = false});
  LayoutState copyWith({List<AppComponent>? components, Color? themePrimaryColor, bool? isEditMode}) {
    return LayoutState(components: components ?? this.components, themePrimaryColor: themePrimaryColor ?? this.themePrimaryColor, isEditMode: isEditMode ?? this.isEditMode);
  }
}

final layoutProvider = StateNotifierProvider<LayoutNotifier, LayoutState>((ref) => LayoutNotifier());

class LayoutNotifier extends StateNotifier<LayoutState> {
  LayoutNotifier() : super(LayoutState(components: _generateDefaultLayout(), themePrimaryColor: const Color(0xFF2196F3)));
  static List<AppComponent> _generateDefaultLayout() {
    return [
      AppComponent(id: 'touchpad_1', label: 'Touchpad', type: ComponentType.touchpad, relativePosition: const Offset(0.05, 0.2), relativeSize: const Size(0.5, 0.6), color: Colors.blueAccent.withOpacity(0.3), actionValue: 'MOUSE_MOVE'),
      AppComponent(id: 'btn_enter', label: 'ENTER', type: ComponentType.button, relativePosition: const Offset(0.6, 0.2), relativeSize: const Size(0.15, 0.15), color: Colors.blue, actionValue: 'ENTER'),
    ];
  }
  void toggleEditMode() => state = state.copyWith(isEditMode: !state.isEditMode);
  void updateComponentPosition(String id, Offset delta, Size screenSize) {
    final updated = state.components.map((c) => c.id == id ? c.copyWith(relativePosition: Offset((c.relativePosition.dx + delta.dx / screenSize.width).clamp(0.0, 1.0), (c.relativePosition.dy + delta.dy / screenSize.height).clamp(0.0, 1.0))) : c).toList();
    state = state.copyWith(components: updated);
  }
  void updateComponentProperty(String id, Map<String, dynamic> updates) {
    final updated = state.components.map((c) => c.id == id ? c.copyWith(label: updates['label'], relativeSize: updates['size'], color: updates['color'], actionValue: updates['action']) : c).toList();
    state = state.copyWith(components: updated);
  }
  void addComponent(ComponentType type) {
    final newComp = AppComponent(id: 'comp_${DateTime.now().millisecondsSinceEpoch}', label: 'New ${type.name}', type: type, relativePosition: const Offset(0.5, 0.5), relativeSize: const Size(0.1, 0.1), color: state.themePrimaryColor, actionValue: 'KEY_A');
    state = state.copyWith(components: [...state.components, newComp]);
  }
  void removeComponent(String id) => state = state.copyWith(components: state.components.where((c) => c.id != id).toList());
}
