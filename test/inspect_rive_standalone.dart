import 'dart:io';
import 'package:rive/rive.dart' as rive;

void main() async {
  try {
    print('Initializing Rive...');
    await rive.Rive.init();
    print('Rive initialized successfully!');
    
    final file = File('assets/onboarding/cooked.riv');
    final bytes = await file.readAsBytes();
    
    print('Decoding Rive file...');
    final riveFile = await rive.File.decode(
      bytes,
      riveFactory: rive.Factory.rive,
    );
    
    final artboard = riveFile?.defaultArtboard();
    if (artboard == null) {
      print('Artboard is null');
      return;
    }
    
    print('ARTBOARD: ${artboard.name}');
    
    final stateMachine = artboard.defaultStateMachine();
    if (stateMachine != null) {
      print('STATE MACHINE: ${stateMachine.name}');
      for (final input in stateMachine.inputs) {
        print('  INPUT: ${input.name} (${input.runtimeType})');
      }
    } else {
      print('No default state machine found');
      // Let's print all state machines
      for (final sm in artboard.stateMachines) {
        print('STATE MACHINE: ${sm.name}');
        for (final input in sm.inputs) {
          print('  INPUT: ${input.name} (${input.runtimeType})');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
  exit(0);
}
