import 'dart:collection';

import 'package:csv/csv.dart';

import '../package/model/package.dart';
import '../package/model/package_root.dart';

class CsvService {
  getDependencyGraphCsv(PackageRoot packageRoot,
      {bool includeSdkCompatibility}) {
    var toWalk = new Queue<Package>();
    var visited = new Set<String>.from([packageRoot.root.name]);
    List<List<String>> csvRows = [
      [
        'package',
        'resolvedVersion',
        'sdkConstraint',
        'isHosted',
        'dependant'
      ], // Header row
      [
        packageRoot.root.name,
        packageRoot.root.version.toString(),
        packageRoot.root.sdkConstraint.toString(),
        '${packageRoot.root.isHosted}',
        ''
      ] // Root package row
    ];

    if (includeSdkCompatibility) {
      csvRows[0].insert(4, 'supportsProvidedSdkVersion');
      csvRows[1].insert(4, '${packageRoot.root.supportsSdkVersion}');
    }

    var immediateDependencies =
        packageRoot.root.dependencies.map((dep) => dep.name).toSet();

    for (var name in immediateDependencies) {
      var immediateDependencyPack = packageRoot.getPackage(name);
      toWalk.add(immediateDependencyPack);

      var immediateDependencyRow = [
        immediateDependencyPack.name,
        immediateDependencyPack.version.toString(),
        immediateDependencyPack.sdkConstraint.toString(),
        '${immediateDependencyPack.isHosted}',
        packageRoot.root.name
      ];

      if (includeSdkCompatibility)
        immediateDependencyRow.insert(
            4, '${immediateDependencyPack.supportsSdkVersion}');
      csvRows.add(immediateDependencyRow);
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

          var depPackRow = [
            depPack.name,
            depPack.version.toString(),
            depPack.sdkConstraint.toString(),
            depPack.isHosted,
            package.name
          ];

          if (includeSdkCompatibility)
            depPackRow.insert(4, '${depPack.supportsSdkVersion}');
          csvRows.add(depPackRow);
        }
      }
    }

    return new ListToCsvConverter().convert(csvRows);
  }
}
