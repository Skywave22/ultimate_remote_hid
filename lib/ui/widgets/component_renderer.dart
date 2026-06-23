import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/layout_engine.dart';
import '../../services/hid_service.dart';

class ComponentRenderer extends ConsumerWidget {
  final AppComponent comp;
  final bool isEditMode;
  final Size screenSize;
  const ComponentRenderer({
    super.key,
    required this.comp,
    required this.isEditMode,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (comp.type) {
      case ComponentType.button:
        return _buildButton(ref);
      case ComponentType.touchpad:
        return _buildTouchpad(ref);
      case ComponentType.joystick:
        return _buildJoystick(ref);
      case ComponentType.slider:
        return _buildSlider(ref);
      case ComponentType.scanner:
        return _buildScanner(ref);
    }
  }

  Widget _buildButton(WidgetRef ref) {
    return GestureDetector(
      onTap: () => isEditMode ? null : ref.read(hidProvider.notifier).sendKey(comp.actionValue),
      child: Container(
        decoration: BoxDecoration(
          color: comp.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEditMode ? [BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 8)] : null,
          border: isEditMode ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Center(
          child: Text(
            comp.label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTouchpad(WidgetRef ref) {
    return GestureDetector(
      onPanUpdate: (details) => isEditMode ? null : ref.read(hidProvider.notifier).sendMouseMove(details.delta.dx / 10, details.delta.dy / 10),
      child: Container(
        decoration: BoxDecoration(
          color: comp.color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: comp.color, width: 2),
        ),
        child: Center(child: Icon(Icons.mouse, color: comp.color, size: 32)),
      ),
    );
  }

  Widget _buildJoystick(WidgetRef ref) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: comp.color.withOpacity(0.2),
            border: Border.all(color: comp.color, width: 3),
          ),
        ),
        GestureDetector(
          onPanUpdate: (details) => isEditMode ? null : ref.read(hidProvider.notifier).sendMouseMove(details.delta.dx, details.delta.dy),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(shape: BoxShape.circle, color: comp.color),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: comp.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: comp.color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(comp.label, style: TextStyle(color: comp.color, fontWeight: FontWeight.bold)),
          Slider(
            value: 0.5,
            onChanged: isEditMode ? null : (v) {},
            activeColor: comp.color,
          ),
        ],
      ),
    );
  }

  Widget _buildScanner(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: comp.color, width: 2),
      ),
      child: Center(
        child: Icon(Icons.qr_code_scanner, color: comp.color, size: 36),
      ),
    );
  }
}
