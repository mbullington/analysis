part of analysis;

/// A source code file resolver.
class SourceResolver implements Function {
  static final _defaultPackageRoots = Platform.packageRoot == null ?
      const [] : [Platform.packageRoot];
  static const _filePrefix = "file:/";

  final SourceFactory _factory;

  /// Create a new default source resolver.
  factory SourceResolver() {
    return new SourceResolver.fromPackageRoots(_defaultPackageRoots);
  }

  /// Create a source resolver using the supplied as package roots.
  factory SourceResolver.fromPackageRoots(
      Iterable<String> packageRoots, [
      bool includeDefaultPackageRoot = true]) {
    final concatPackageRoots = packageRoots.toList();
    if (includeDefaultPackageRoot) {
      concatPackageRoots.addAll(_defaultPackageRoots);
    }
    return new SourceResolver._(_createResolver(concatPackageRoots));
  }

  SourceResolver._(PackageUriResolver packageUriResolver):
    _factory = new SourceFactory([packageUriResolver,
        new DartUriResolver(DirectoryBasedDartSdk.defaultSdk)]);

  /// Resolve and returns [path]. For example:
  ///     // Returns (for example) /home/ubuntu/user/libs/analysis/analysis.dart
  ///     resolver("package:analysis/analysis.dart")
  String call(String path) {
    // Translate path to an absolute path.
    if (path.startsWith("package:") || path.startsWith("dart:")) {
      path = _factory.forUri(path).toString();
      final filePathIndex = path.indexOf(_filePrefix);
      if (filePathIndex != -1) {
        path = path.substring(filePathIndex + _filePrefix.length - 1);
      }
    } else {
      throw new ArgumentError.value(path, "path", "Not in 'package:' format.");
    }
    return new JavaFile(path).getAbsolutePath();
  }

  /// Creates and returns a URI resolver.
  static PackageUriResolver _createResolver([Iterable<String> packageRoots]) {
    final packageRootResolvers = packageRoots.map((packageRoot) {
      return new JavaFile.fromUri(new Uri.file(packageRoot));
    }).toList(growable: false);
    return new PackageUriResolver(packageRootResolvers);
  }
}
