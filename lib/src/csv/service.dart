import 'dart:collection';

import 'package:csv/csv.dart';

import '../package/model/package.dart';
import '../package/model/package_root.dart';

class CsvService {
  getDependencyGraphCsv(PackageRoot packageRoot) {
    var toWalk = new Queue<Package>();
    var visited = new Set<String>.from([packageRoot.root.name]);
    var csvRows = [
      [
        'package',
        'resolvedVersion',
        'sdkConstraint',
        'dependant'
      ], // Header row
      [
        packageRoot.root.name,
        packageRoot.root.version.toString(),
        packageRoot.root.sdkConstraint.toString(),
        ''
      ]
    ];

    var immediateDependencies =
        packageRoot.root.dependencies.map((dep) => dep.name).toSet();

    for (var name in immediateDependencies) {
      var immediateDependencyPack = packageRoot.getPackage(name);
      toWalk.add(immediateDependencyPack);
      csvRows.add([
        immediateDependencyPack.name,
        immediateDependencyPack.version.toString(),
        immediateDependencyPack.sdkConstraint.toString(),
        packageRoot.root.name
      ]);
    }

    while (toWalk.isNotEmpty) {
      var package = toWalk.removeFirst();

      if (visited.contains(package.name)) continue;

      visited.add(package.name);

      for (var dep in package.dependencies) {
        var depPack = packageRoot.getPackage(dep.name);

        // TODO: For some reason, some transitives are listed that aren't resolved within the dependency tree.
        if (depPack != null) {
          toWalk.add(depPack);
          csvRows.add([
            depPack.name,
            depPack.version.toString(),
            depPack.sdkConstraint.toString(),
            package.name
          ]);
        }
      }
    }

    return new ListToCsvConverter().convert(csvRows);
  }
}
