import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We can use RiveNative.init() if supported, but let's do it inside the app
  runApp(const RiveTestApp());
}

class RiveTestApp extends StatelessWidget {
  const RiveTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rive Input Tester',
      theme: ThemeData.dark(),
      home: const RiveTesterScreen(),
    );
  }
}

class RiveTesterScreen extends StatefulWidget {
  const RiveTesterScreen({super.key});

  @override
  State<RiveTesterScreen> createState() => _RiveTesterScreenState();
}

class _RiveTesterScreenState extends State<RiveTesterScreen> {
  rive.FileLoader? _fileLoader;
  rive.StateMachine? _stateMachine;
  
  bool _bool1 = false;
  bool _bool2 = false;
  String _status = "Loading file...";

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      // First initialize native
      await rive.RiveNative.init();
      setState(() {
        _status = "Rive initialized, loading asset...";
      });
      
      final file = await rive.File.asset(
        'assets/onboarding/cooked.riv',
        riveFactory: rive.Factory.rive, // Try rive factory, if web/desktop it should work
        assetLoader: _loadRiveAsset,
      );
      if (mounted && file != null) {
        setState(() {
          _fileLoader = rive.FileLoader.fromFile(file, riveFactory: rive.Factory.rive);
          _status = "File loaded. Waiting for artboard...";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error loading: $e";
      });
    }
  }

  bool _loadRiveAsset(rive.FileAsset fileAsset, Uint8List? bytes) {
    if (fileAsset is rive.FontAsset) {
      rootBundle.load('assets/fonts/Larken/Larken Bold-6264325.ttf').then((fontData) async {
        final fontBytes = fontData.buffer.asUint8List();
        await fileAsset.decode(fontBytes);
      }).catchError((e) {
        print("Font error: $e");
      });
      return true;
    }
    return false;
  }

  void _updateBool1(bool val) {
    setState(() {
      _bool1 = val;
    });
    final input = _stateMachine?.boolean('Boolean 1');
    if (input != null) {
      input.value = val;
    }
  }

  void _updateBool2(bool val) {
    setState(() {
      _bool2 = val;
    });
    final input = _stateMachine?.boolean('Boolean 2');
    if (input != null) {
      input.value = val;
    }
  }

  void _fireTrigger1() {
    final input = _stateMachine?.trigger('Trigger 1');
    if (input != null) {
      input.fire();
    }
  }

  void _fireTrigger2() {
    final input = _stateMachine?.trigger('Trigger 2');
    if (input != null) {
      input.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left panel: Rive animation
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[900],
              child: _fileLoader == null
                  ? Center(child: Text(_status))
                  : rive.RiveWidgetBuilder(
                      fileLoader: _fileLoader!,
                      onLoaded: (riveLoadedState) {
                        final controller = riveLoadedState.controller;
                        _stateMachine = controller.stateMachine;
                        setState(() {
                          _status = "StateMachine loaded: ${_stateMachine!.name}";
                        });
                        // Sync initial UI values to inputs
                        _updateBool1(_bool1);
                        _updateBool2(_bool2);
                      },
                      builder: (context, state) => switch (state) {
                        rive.RiveLoaded() => rive.RiveWidget(
                            controller: state.controller,
                            fit: rive.Fit.contain,
                          ),
                        rive.RiveFailed() => const Center(
                            child: Text('Error loading animation'),
                          ),
                        _ => const Center(
                            child: CircularProgressIndicator(),
                          ),
                      },
                    ),
            ),
          ),
          
          // Right panel: Controls
          Container(
            width: 300,
            color: Colors.grey[850],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rive Control Panel',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Status: $_status', style: const TextStyle(color: Colors.grey)),
                const Divider(height: 30),
                
                // Boolean 1 Switch
                SwitchListTile(
                  title: const Text('Boolean 1'),
                  subtitle: const Text('Toggle input'),
                  value: _bool1,
                  onChanged: _updateBool1,
                ),
                
                // Boolean 2 Switch
                SwitchListTile(
                  title: const Text('Boolean 2'),
                  subtitle: const Text('Toggle input'),
                  value: _bool2,
                  onChanged: _updateBool2,
                ),
                
                const SizedBox(height: 20),
                
                // Trigger 1 Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _fireTrigger1,
                    child: const Text('Fire Trigger 1'),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Trigger 2 Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _fireTrigger2,
                    child: const Text('Fire Trigger 2'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
