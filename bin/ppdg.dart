import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'package:pub_package_dependency_graph/pub_package_dependency_graph.dart';

void main(List<String> arguments) {
  final parser = new ArgParser();
  parser.addOption('path', abbr: 'p', defaultsTo: path.current);

  final parsedArgs = parser.parse(arguments);

  final pubPackageDependencyGraphService =
      new PubPackageDependencyGraphService();
  pubPackageDependencyGraphService.getPackageFromDirectory(
      parsedArgs.rest.isNotEmpty ? parsedArgs.rest[0] : parsedArgs['path']);
}
