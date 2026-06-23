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
    required this.screenSize
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
      onTap: () {
        if (!isEditMode) {
          ref.read(hidProvider.notifier).sendKey(comp.actionValue);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: comp.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Center(
          child: Text(
            comp.label, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
          ),
        ),
      ),
    );
  }

  Widget _buildTouchpad(WidgetRef ref) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (!isEditMode) {
          double dx = details.delta.dx / 10; 
          double dy = details.delta.dy / 10;
          ref.read(hidProvider.notifier).sendMouseMove(dx, dy);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: comp.color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: comp.color, width: 2),
        ),
        child: Center(
          child: Icon(Icons.mouse, color: comp.color.withOpacity(0.5), size: 40),
        ),
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
          onPanUpdate: (details) {
            if (!isEditMode) {
              ref.read(hidProvider.notifier).sendMouseMove(details.delta.dx, details.delta.dy);
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: comp.color,
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(WidgetRef ref) {
    return Slider(
      value: 0.5, 
      activeColor: comp.color,
      onChanged: (val) {
        if (!isEditMode) {
          ref.read(hidProvider.notifier).sendKey(comp.actionValue == 'VOL_UP' ? 'VOL_UP' : 'VOL_DOWN');
        }
      },
    );
  }

  Widget _buildScanner(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!isEditMode) {
          print("Opening QR Scanner...");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: comp.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
    );
  }
}
