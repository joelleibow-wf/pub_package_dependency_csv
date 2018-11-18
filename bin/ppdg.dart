import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'package:pub_package_dependency_graph/pub_package_dependency_graph.dart';

main(List<String> arguments) async {
  final parser = new ArgParser();
  parser.addOption('path', abbr: 'p', defaultsTo: path.current);

  final parsedArgs = parser.parse(arguments);

  final pubPackageDependencyGraphService =
      new PubPackageDependencyGraphService();
  final packageRoot =
      await pubPackageDependencyGraphService.getPackageFromDirectory(
          parsedArgs.rest.isNotEmpty ? parsedArgs.rest[0] : parsedArgs['path']);

  final now = new DateTime.now();
  _writeCsvFile(new CsvService().getDependencyGraphCsv(packageRoot),
      '${now.year}${now.month}${now.day}_${packageRoot.root.name}.csv');
}

_writeCsvFile(String csv, String fileName) {
  new File(path.join('tool', 'csv', fileName)).writeAsString(csv);
}
