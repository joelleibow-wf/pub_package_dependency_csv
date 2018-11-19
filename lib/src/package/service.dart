import 'dart:async';

import 'package:pub_semver/pub_semver.dart';

import './model/package_root.dart';

class PubPackageDependencyGraphService {
  Future<PackageRoot> getPackageFromDirectory(String packagePath,
      {Version compatibleWithSdkVersion}) async {
    return await PackageRoot.forDirectory(packagePath,
        compatibleWithSdkVersion: compatibleWithSdkVersion);
  }
}
