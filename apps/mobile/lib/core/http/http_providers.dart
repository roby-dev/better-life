import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';
import '../error/problem_details_parser.dart';
import '../storage/storage_providers.dart';
import 'dio_client.dart';

final problemDetailsParserProvider = Provider<ProblemDetailsParser>(
  (_) => const ProblemDetailsParser(),
);

final dioProvider = Provider<Dio>((ref) => buildDio(
      config: ref.watch(appConfigProvider),
      tokenStorage: ref.watch(tokenStorageProvider),
      parser: ref.watch(problemDetailsParserProvider),
    ));
