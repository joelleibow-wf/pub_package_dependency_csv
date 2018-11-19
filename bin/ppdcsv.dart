import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

import 'package:pub_package_dependency_csv/pub_package_dependency_csv.dart';

main(List<String> arguments) async {
  final parser = new ArgParser();
  parser.addOption('path', abbr: 'p', defaultsTo: path.current);
  parser.addOption('compatibleWithSdkVersion', abbr: 's');

  final parsedArgs = parser.parse(arguments);

  final pubPackageDependencyGraphService =
      new PubPackageDependencyGraphService();
  final packageRoot =
      await pubPackageDependencyGraphService.getPackageFromDirectory(
          parsedArgs.rest.isNotEmpty ? parsedArgs.rest[0] : parsedArgs['path'],
          compatibleWithSdkVersion:
              (parsedArgs['compatibleWithSdkVersion'] != null)
                  ? new Version.parse(parsedArgs['compatibleWithSdkVersion'])
                  : null);

  final now = new DateTime.now();
  _writeCsvFile(
      new CsvService().getDependencyGraphCsv(packageRoot,
          includeSdkCompatibility:
              (parsedArgs['compatibleWithSdkVersion'] != null)),
      '${now.year}${now.month}${now.day}_${packageRoot.root.name}.csv');
}

_writeCsvFile(String csv, String fileName) {
  new File(path.join('tool', 'csv', fileName)).writeAsString(csv);
}
