import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout_engine.dart';
import '../../services/hid_service.dart';

class ComponentRenderer extends ConsumerWidget {
  final AppComponent comp; final bool isEditMode; final Size screenSize;
  const ComponentRenderer({super.key, required this.comp, required this.isEditMode, required this.screenSize});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (comp.type == ComponentType.button) return _buildButton(ref);
    if (comp.type == ComponentType.touchpad) return _buildTouchpad(ref);
    if (comp.type == ComponentType.joystick) return _buildJoystick(ref);
    return Container();
  }
  Widget _buildButton(WidgetRef ref) => GestureDetector(onTap: () => isEditMode ? null : ref.read(hidProvider.notifier).sendKey(comp.actionValue), child: Container(decoration: BoxDecoration(color: comp.color, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(comp.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))));
  Widget _buildTouchpad(WidgetRef ref) => GestureDetector(onPanUpdate: (details) => isEditMode ? null : ref.read(hidProvider.notifier).sendMouseMove(details.delta.dx/10, details.delta.dy/10), child: Container(decoration: BoxDecoration(color: comp.color.withOpacity(0.4), borderRadius: BorderRadius.circular(20), border: Border.all(color: comp.color, width: 2)), child: Center(child: Icon(Icons.mouse, color: comp.color))));
  Widget _buildJoystick(WidgetRef ref) => Stack(alignment: Alignment.center, children: [Container(decoration: BoxDecoration(shape: BoxShape.circle, color: comp.color.withOpacity(0.2), border: Border.all(color: comp.color, width: 3))), GestureDetector(onPanUpdate: (details) => isEditMode ? null : ref.read(hidProvider.notifier).sendMouseMove(details.delta.dx, details.delta.dy), child: Container(width: 50, height: 50, decoration: BoxDecoration(shape: BoxShape.circle, color: comp.color)))]));
}
