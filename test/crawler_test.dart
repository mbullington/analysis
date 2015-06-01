library analysis.test.resolver_test;

import 'package:analysis/analysis.dart';
import 'package:test/test.dart';

void main() {
  group('SourceCrawler', () {
    final sourceCrawler = new SourceCrawler();

    test('can run on test_data.dart', () async {
      final librariesLoaded =
          sourceCrawler('package:analysis/src/test_data/test_data.dart')
            .map((LibraryTuple library) => library.name)
            .toList();

      expect(librariesLoaded, [
        'test_data',
        'test_import'
      ]);
    });
  });
}
