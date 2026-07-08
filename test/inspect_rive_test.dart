import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart' as rive;

void main() {
  test('inspect cooked.riv inputs', () async {
    final file = File('assets/onboarding/cooked.riv');
    final bytes = await file.readAsBytes();
    
    print('Initializing Rive in test...');
    await rive.RiveNative.init();
    print('Rive initialized.');
    final riveFile = await rive.File.decode(
      bytes,
      riveFactory: rive.Factory.flutter,
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
    }
  }, skip: 'Skipped on CI because RiveNative.init() fails in some headless environments');
}
