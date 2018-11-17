import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

class Dependency {
  final String name;
  final VersionConstraint versionConstraint;
  final bool isDevDependency;

  bool _includesLatest;

  /// Also true if there is a pre-release version after the latest version
  bool get includesLatest => _includesLatest;

  set includesLatest(bool value) {
    assert(_includesLatest == null);
    assert(value != null);

    _includesLatest = value;
  }

  Dependency._(this.name, String versionConstraint, this.isDevDependency)
      : this.versionConstraint = _parseOrNull(versionConstraint);

  static Set<Dependency> getDependencies(YamlMap pubspec) {
    var deps = new Set<Dependency>();

    _populateFromSection(pubspec['dependencies'] ?? {}, deps, false);
    _populateFromSection(pubspec['dev_dependencies'] ?? {}, deps, true);

    return deps;
  }

  static void _populateFromSection(
      YamlMap yaml, Set<Dependency> value, bool isDev) {
    yaml.forEach((String key, constraint) {
      String constraintString;
      if (constraint is YamlMap) {
        constraintString = constraint['version'];
      } else {
        constraintString = constraint;
      }

      var dep = new Dependency._(key, constraintString, isDev);
      assert(!value.contains(dep));

      value.add(dep);
    });
  }

  @override
  bool operator ==(other) => other is Dependency && other.name == name;

  @override
  int get hashCode => name.hashCode;

  // @override
  // int compareTo(Dependency other) {
  //   if (other.isDevDependency == isDevDependency) {
  //     return name.compareTo(other.name);
  //   } else if (isDevDependency) {
  //     return 1;
  //   } else {
  //     return -1;
  //   }
  // }

  @override
  String toString() {
    var devStr = isDevDependency ? '(dev)' : '';
    return '$name$devStr $versionConstraint';
  }
}

VersionConstraint _parseOrNull(String input) {
  try {
    return new VersionConstraint.parse(input);
  } catch (e) {
    return VersionConstraint.empty;
  }
}
