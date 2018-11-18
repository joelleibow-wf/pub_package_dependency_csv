import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import './dependency.dart';
import './package.dart';

class PackageRoot {
  final Package root;
  final Map<String, Package> packages;

  PackageRoot._(this.root, Map<String, Package> packages)
      : this.packages = new UnmodifiableMapView(packages);

  static Future<PackageRoot> forDirectory(String path) async {
    var root = await Package.forDirectory(path);
    var packages = await _getReferencedPackages(path);

    // want to make sure that the root node instance is the same
    // as the instance in the packages collection
    root = packages[root.name];
    assert(root != null);

    var packageRoot = new PackageRoot._(root, packages);

    packageRoot._update();

    return packageRoot;
  }

  Package getPackage(String packageName) {
    return packages[packageName];
  }

  void _update() {
    if (root.isPrimary == false) {
      root.isPrimary = true;

      assert(root.onlyDev);
      root.onlyDev = false;

      for (var primaryDep in root.dependencies) {
        var package = packages[primaryDep.name];

        assert(!package.isPrimary);
        package.isPrimary = true;

        if (!primaryDep.isDevDependency) {
          _updateDevOnly(primaryDep);
        }
      }
    }
  }

  void _updateDevOnly(Dependency dep) {
    var package = packages[dep.name];

    if (package.onlyDev) {
      package.onlyDev = false;

      package.dependencies
          .where((d) => !d.isDevDependency)
          .forEach(_updateDevOnly);
    }
  }
}

Future<Map<String, String>> _getPackageMap(String path) async {
  var map = new Map<String, String>();

  var proc = 'pub';
  var args = ['list-package-dirs'];

  var result =
      await Process.run(proc, args, runInShell: true, workingDirectory: path);

  if (result.exitCode != 0) {
    var message = result.stderr as String;
    try {
      var value = JSON.decode(result.stdout as String) as Map;
      if (value.containsKey('error')) {
        message = value['error'] as String;
      }
    } catch (e) {
      // NOOP
    }

    throw new ProcessException(
        'pub', ['list-package-dirs'], message, result.exitCode);
  }

  var json = JSON.decode(result.stdout as String);

  var packages = json['packages'] as Map<String, dynamic>;

  packages.forEach((k, v) {
    assert(p.basename(v as String) == 'lib');
    map[k] = p.dirname(v as String);
  });

  return map;
}

Future<Map<String, Package>> _getReferencedPackages(String path) async {
  var packs = new SplayTreeMap<String, Package>();

  Map<String, String> map;
  try {
    map = await _getPackageMap(path);
  } on ProcessException catch (e) {
    print(e.message);
  }

  List packaageNames = map.keys.toList();
  for (var i = 0; i < packaageNames.length; i++) {
    var subPath = map[packaageNames[i]];
    var vp = await Package.forDirectory(subPath);
    assert(vp.name == packaageNames[i]);

    assert(!packs.containsKey(vp.name));
    assert(!packs.containsValue(vp));
    packs[vp.name] = vp;
  }

  return packs;
}
