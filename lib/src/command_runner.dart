import 'package:args/command_runner.dart';

class PubPackageDependencyGraphCommandRunner extends CommandRunner {
  PubPackageDependencyGraphCommandRunner()
      : super('ppdg',
            'Pub package dependency graph generates a graph of all dependencies for a package.');
}
