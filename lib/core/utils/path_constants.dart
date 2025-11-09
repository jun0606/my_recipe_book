// lib/core/utils/path_constants.dart
// 프로젝트 내 주요 경로들을 상수로 정의하여 import 경로 단순화

class PathConstants {
  // Core paths
  static const String core = 'package:my_recipe_book/core';
  static const String coreTypes = '$core/types';
  static const String coreUtils = '$core/utils';
  static const String coreServices = '$core/services';

  // Features paths
  static const String features = 'package:my_recipe_book/features';
  static const String featuresChef = '$features/chef';
  static const String featuresChefModule = '$featuresChef/module';
  static const String featuresChefModuleBread = '$featuresChefModule/bread';
  static const String featuresChefModuleBreadTypes =
      '$featuresChefModuleBread/types';
  static const String featuresChefModuleBreadServices =
      '$featuresChefModuleBread/services';

  // Services paths
  static const String services = 'package:my_recipe_book/services';
  static const String models = 'package:my_recipe_book/models';
  static const String data = 'package:my_recipe_book/data';

  // Common relative paths for deep imports
  static const String relativeCoreTypes = '../../../../../core/types';
  static const String relativeCoreUtils = '../../../../../core/utils';
  static const String relativeCoreServices = '../../../../../core/services';
  static const String relativeFeaturesChef = '../../../';
  static const String relativeFeaturesChefModule = '../../';
  static const String relativeServices = '../../../../services';
  static const String relativeModels = '../../../../models';
  static const String relativeData = '../../../data';
}
