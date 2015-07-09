part of analysis;

class LibraryTuple {
  final CompilationUnit astUnit;

  final String path;
  final String packageUri;

  List<CompilationUnit> parts = [];

  List<CompilationUnit> get astUnits =>
    []..addAll(parts)..add(astUnit);

  String get name {
    String name;
    astUnit.directives
      .where((e) => e is LibraryDirective)
      .forEach((e) {
        name = e.name.name;
      });
    return name;
  }

  LibraryTuple._(this.astUnit, [this.path, this.packageUri]);
}

abstract class SourceCrawler implements Function {
  factory SourceCrawler({
      bool analyzeFunctionBodies: false,
      bool includeDefaultPackageRoot: true,
      List<String> packageRoots,
      bool preserveComments: false,
      List<String> allowedDartPaths}) =>
          new _SourceCrawler(analyzeFunctionBodies, includeDefaultPackageRoot, packageRoots, preserveComments, allowedDartPaths);

  /// Resolves and crawls [path], and all files imported (recursively). Returns
  /// an [Iterable] of all the ASTs parsed.
  Iterable<LibraryTuple> call(String path);
  Iterable<LibraryTuple> crawl(String entryPointLocation, [bool deep = false]);
}

/// A source code crawler.
class _SourceCrawler implements SourceCrawler {
  final Map<String, LibraryTuple> _libraries = {};
  final SourceResolver _sourceResolver;

  final List<String> allowedDartPaths;

  factory _SourceCrawler(
      bool analyzeFunctionBodies,
      bool includeDefaultPackageRoot,
      List<String> packageRoots,
      bool preserveComments,
      List<String> allowedDartPaths) {
    if (packageRoots == null) {
      packageRoots = [Platform.packageRoot];
    }

    // Create a resolver to use.
    final sourceResolver = new SourceResolver.fromPackageRoots(
        packageRoots, includeDefaultPackageRoot);

    return new _SourceCrawler._(sourceResolver, allowedDartPaths);
  }

  _SourceCrawler._(this._sourceResolver, [this.allowedDartPaths = const []]);

  /// Crawls, starting at [path], invoking [crawlFile] for each file.
  @override
  Iterable<LibraryTuple> call(String entryPointLocation) {
    return crawl(entryPointLocation);
  }

  Iterable<LibraryTuple> crawl(String entryPointLocation, [bool deep = false]) {
    final path = _getFileLocation(entryPointLocation);
    final results = <LibraryTuple>[];

    if(_libraries.containsKey(path)) {
      results.add(_libraries[path]);
    } else {
      final astUnit = parseDartFile(path);
      var lib = new LibraryTuple._(astUnit, path);

      astUnit.directives
        .where((directive) => directive is PartDirective)
        .forEach((UriBasedDirective import) {
          final path = _getFileLocation(import.uri.stringValue, lib.path);
          if(path != null) {
            lib.parts.addAll(this.crawl(path, true).map((l) => l.astUnit));
          }
        });

      results.add(lib);
      _libraries[path] = lib;
    }

    results.first.astUnit.directives
      .where((directive) =>
        deep ? directive is ExportDirective :
        directive is ImportDirective || directive is ExportDirective)
      .forEach((UriBasedDirective import) {
        final path = _getFileLocation(import.uri.stringValue, results.first.path);
        if(path != null) {
          results.addAll(this.crawl(path, true));
        }
      });

    return results;
  }

  String _getFileLocation(String uri, [String relativeTo]) {
    if (uri == null || (uri.startsWith("dart:") && !allowedDartPaths.contains(uri))) {
      return null;
    } else if (uri.startsWith("package:") || uri.startsWith("dart:")) {
      return _sourceResolver(uri);
    } else {
      if(relativeTo != null)
        return path.join(path.dirname(relativeTo), uri);
      return path.absolute(uri);
    }
  }
}
