import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import './dependency.dart';

class Package {
  final String name;
  final Version version;
  final Set<Dependency> dependencies;
  final VersionConstraint sdkConstraint;
  bool isPrimary = false;

  bool _onlyDev = true;

  bool get onlyDev => _onlyDev;

  set onlyDev(bool value) {
    assert(value == false);
    assert(_onlyDev == true);

    _onlyDev = value;
  }

  Version _latestVersion;

  Version get latestVersion => _latestVersion;

  Package._(this.name, this.version, Set<Dependency> deps, this.sdkConstraint)
      : dependencies = new UnmodifiableSetView(deps);

  static Future<Package> forDirectory(String path) async {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    var pubspec = loadYaml(new File(pubspecPath).readAsStringSync(),
        sourceUrl: pubspecPath);
    var deps = Dependency.getDependencies(pubspec);
    var sdkConstraint =
        (pubspec['environment'] != null) ? pubspec['environment']['sdk'] : null;

    var package =
        new Package._(pubspec['name'], pubspec['version'], deps, sdkConstraint);

    return package;
  }

  @override
  String toString() => '$name @ $version';

  // @override
  // int compareTo(Package other) {
  //   return name.compareTo(other.name);
  // }

  @override
  bool operator ==(Object other) {
    if (other is Package) {
      var match = (name == other.name);
      if (match) {
        assert(other.version == version);
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}