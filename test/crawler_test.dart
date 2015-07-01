library analysis.test.resolver_test;

import 'package:analysis/analysis.dart';
import 'package:test/test.dart';

void main() {
  group('SourceCrawler', () {
    final sourceCrawler = new SourceCrawler();

    test('can run on test_data.dart', () async {
      var crawler = sourceCrawler('package:analysis/src/test_data/test_data.dart');
      final librariesLoaded =
            crawler
            .map((LibraryTuple library) => library.name)
            .toList();

      print(crawler[0].path);
      expect(crawler[0].name, 'test_data');

      expect(librariesLoaded, [
        'test_data',
        'test_import'
      ]);

      expect(crawler[0].parts.length, 1);
      expect(crawler[0].astUnits.length, 2);
    });
  });
}
