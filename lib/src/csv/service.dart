import 'dart:collection';

import 'package:csv/csv.dart';

import '../package/model/package.dart';
import '../package/model/package_root.dart';

class CsvService {
  getDependencyGraphCsv(PackageRoot packageRoot,
      {bool includeSdkCompatibility}) {
    var toWalk = new Queue<Package>();
    var isKnown = new Set<String>.from([packageRoot.root.name]);

    List<List<String>> csvRows = [
      [
        'package',
        'resolvedVersion',
        'sdkConstraint',
        'isHosted',
        'dependent',
        'devDependent'
      ], // Header row
      [
        packageRoot.root.name,
        packageRoot.root.version.toString(),
        packageRoot.root.sdkConstraint.toString(),
        '${packageRoot.root.isHosted}',
        '',
        ''
      ] // Root package row
    ];

    if (includeSdkCompatibility) {
      csvRows[0].insert((csvRows[0].length - 2),
          'supportsProvidedSdkVersion'); // We always want dependant and devDependent as the last 2 columns
      csvRows[1].insert((csvRows[1].length - 2),
          '${packageRoot.root.supportsSdkVersion}'); // We always want dependant and devDependent as the last 2 columns
    }

    var immediateDependencies =
        packageRoot.root.dependencies.map((dep) => dep).toSet();

    for (var immediateDep in immediateDependencies) {
      var immediateDependencyPack = packageRoot.getPackage(immediateDep.name);
      toWalk.add(immediateDependencyPack);

      var immediateDependencyRow = [
        immediateDependencyPack.name,
        immediateDependencyPack.version.toString(),
        immediateDependencyPack.sdkConstraint.toString(),
        '${immediateDependencyPack.isHosted}'
      ];

      var dependentType = (immediateDep.isDevDependency)
          ? ['', packageRoot.root.name]
          : [packageRoot.root.name, ''];
      immediateDependencyRow.addAll(dependentType);

      if (includeSdkCompatibility)
        immediateDependencyRow.insert((immediateDependencyRow.length - 2),
            '${immediateDependencyPack.supportsSdkVersion}'); // We always want dependant and devDependent as the last 2 columns
      csvRows.add(immediateDependencyRow);
    }

    while (toWalk.isNotEmpty) {
      var package = toWalk.removeFirst();

      if (isKnown.contains(package.name)) continue;

      isKnown.add(package.name);

      for (var dep in package.dependencies) {
        var depPack = packageRoot.getPackage(dep.name);

        // TODO: For some reason, some transitives are listed that aren't resolved within the dependency tree.
        if (depPack != null) {
          toWalk.add(depPack);

          var depPackRow = [
            depPack.name,
            depPack.version.toString(),
            depPack.sdkConstraint.toString(),
            depPack.isHosted
          ];

          var dependentType =
              (dep.isDevDependency) ? ['', package.name] : [package.name, ''];
          depPackRow.addAll(dependentType);

          if (includeSdkCompatibility)
            depPackRow.insert((depPackRow.length - 2),
                '${depPack.supportsSdkVersion}'); // We always want dependant and devDependent as the last 2 columns
          csvRows.add(depPackRow);
        }
      }
    }

    return new ListToCsvConverter().convert(csvRows);
  }
}
