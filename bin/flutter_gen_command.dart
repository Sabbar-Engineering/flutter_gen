import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:flutter_gen/src/utils/file.dart';

void main(List<String> args) {
  final parser = ArgParser();
  parser.addOption(
    'config',
    abbr: 'c',
    defaultsTo: 'pubspec.yaml',
    help: 'Set the path of pubspec.yaml.',
  );

  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'Help about any command',
    defaultsTo: false,
  );

  final results = parser.parse(args);
  if (results.wasParsed('help')) {
    print(parser.usage);
    return;
  }

  final pubspecPath = results['config'] as String;
  FlutterGenerator(File(pubspecPath).absolute).build();
}

class FlutterGenerator {
  const FlutterGenerator(this.pubspecFile);

  final File pubspecFile;

  Future<void> build() async {
    final config = await Config(pubspecFile).load();

    String output;
    int lineLength;

    if (config.hasFlutterGen) {
      output = config.flutterGen.output;
      lineLength = config.flutterGen.lineLength;
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutterGen.hasColors) {
        final generated = ColorsGenerator.generate(
            pubspecFile, formatter, config.flutterGen.colors);
        final colors =
            File('${pubspecFile.parent.path}/$output/color.gen.dart');
        writeAsString(generated, file: colors);
      }
    }

    if (config.hasFlutter) {
      final formatter = DartFormatter(pageWidth: lineLength);

      if (config.flutter.hasAssets) {
        final generated = AssetsGenerator.generate(
            pubspecFile, formatter, config.flutter.assets);
        final assets =
            File('${pubspecFile.parent.path}/$output/assets.gen.dart');
        writeAsString(generated, file: assets);
      }

      if (config.flutter.hasFonts) {
        final generated =
            FontsGenerator.generate(formatter, config.flutter.fonts);
        final fonts = File('${pubspecFile.parent.path}/$output/fonts.gen.dart');
        writeAsString(generated, file: fonts);
      }
    }
  }
}
