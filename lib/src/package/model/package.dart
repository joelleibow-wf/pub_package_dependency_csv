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
  final String publishTo;
  final Set<Dependency> dependencies;
  final VersionConstraint sdkConstraint;
  final Version compatibleWithSdkVersion;
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

  bool get isHosted =>
      (publishTo != null) && (publishTo != 'https://pub.dartlang.org/');

  bool get supportsSdkVersion =>
      (compatibleWithSdkVersion != null && sdkConstraint != null) &&
      sdkConstraint.allows(compatibleWithSdkVersion);

  Package._(this.name, this.version, this.publishTo, Set<Dependency> deps,
      this.sdkConstraint,
      {this.compatibleWithSdkVersion})
      : dependencies = new UnmodifiableSetView(deps);

  static Future<Package> forDirectory(String path,
      {Version compatibleWithSdkVersion}) async {
    var dir = new Directory(path);
    assert(dir.existsSync());

    var pubspecPath = p.join(path, 'pubspec.yaml');

    var pubspec = loadYaml(new File(pubspecPath).readAsStringSync(),
        sourceUrl: pubspecPath);
    var deps = Dependency.getDependencies(pubspec);
    var sdkConstraint = (pubspec['environment'] != null)
        ? new VersionConstraint.parse(pubspec['environment']['sdk'])
        : null;

    var package = new Package._(pubspec['name'], pubspec['version'],
        pubspec['publish_to'], deps, sdkConstraint,
        compatibleWithSdkVersion: compatibleWithSdkVersion);

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
