import 'dart:async';

import './model/package_root.dart';

class PubPackageDependencyGraphService {
  Future<PackageRoot> getPackageFromDirectory(String packagePath) async {
    return await PackageRoot.forDirectory(packagePath);
  }
}
