import 'dart:async';

import './model/package.dart';

class PubPackageDependencyGraphService {
  Future<Package> getPackageFromDirectory(String packagePath) async {
    return await Package.forDirectory(packagePath);
  }
}
