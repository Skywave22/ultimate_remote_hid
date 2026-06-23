import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/layout_engine.dart';
import 'services/hid_service.dart';
import 'ui/widgets/component_renderer.dart';
import 'ui/widgets/connection_banner.dart';
import 'ui/widgets/power_mode_panel.dart';

void main() { runApp(const ProviderScope(child: RemoteHIDApp())); }
class RemoteHIDApp extends StatelessWidget {
  const RemoteHIDApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Ultimate Remote HID', theme: ThemeData(useMaterial3: true), home: const MainControllerScreen());
  }
}
class MainControllerScreen extends ConsumerStatefulWidget {
  const MainControllerScreen({super.key});
  @override
  ConsumerState<MainControllerScreen> createState() => _MainControllerScreenState();
}
class _MainControllerScreenState extends ConsumerState<MainControllerScreen> {
  void _showPowerPanel(AppComponent comp) { showModalBottomSheet(context: context, builder: (context) => PowerModePanel(selectedComp: comp)); }
  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(layoutProvider);
    return Scaffold(body: SafeArea(child: Column(children: [
      const ConnectionBanner(),
      Expanded(child: OrientationBuilder(builder: (context, orientation) {
        return LayoutBuilder(builder: (context, constraints) {
          return Stack(children: [
            ...layout.components.map((comp) => Positioned(
              left: comp.relativePosition.dx * constraints.maxWidth,
              top: comp.relativePosition.dy * constraints.maxHeight,
              child: GestureDetector(
                onPanUpdate: (details) => layout.isEditMode ? ref.read(layoutProvider.notifier).updateComponentPosition(comp.id, details.delta, constraints.biggest) : null,
                onTap: () => layout.isEditMode ? _showPowerPanel(comp) : ref.read(hidProvider.notifier).sendKey(comp.actionValue),
                child: ComponentRenderer(comp: comp, isEditMode: layout.isEditMode, screenSize: constraints.biggest),
              ),
            ))),
            Positioned(top: 20, right: 20, child: Column(children: [
              FloatingActionButton(onPressed: () => ref.read(layoutProvider.notifier).toggleEditMode(), child: Icon(layout.isEditMode ? Icons.save : Icons.edit)),
              if (layout.isEditMode) FloatingActionButton(onPressed: () => ref.read(layoutProvider.notifier).addComponent(ComponentType.button), child: const Icon(Icons.add)),
            ])),
          ]);
        }),
      })),
    ], ))),
  );
}
