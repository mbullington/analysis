library analysis.test.resolver_test;

import 'dart:io';

import 'package:analysis/analysis.dart';
import 'package:test/test.dart';

void main() {
  group('SourceResolver', () {
    final sourceResolver = new SourceResolver();

    test('can find the path to resolver.dart', () async {
      final path = sourceResolver('package:analysis/src/resolver.dart');
      expect(path, endsWith('resolver.dart'));
      final String file = await new File(path).readAsString();
      expect(file, startsWith('part of analysis;'));
    });
  });
}
