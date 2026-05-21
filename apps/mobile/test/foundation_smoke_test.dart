// ignore_for_file: unused_import
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Foundation smoke', () {
    test('all S1 dependencies compile', () {
      // If the imports above resolve, this test confirms compilation.
      expect(true, isTrue);
    });

    test('betterlife_logo.svg asset exists on disk', () {
      // Path is relative to the project root where flutter test runs (apps/mobile/).
      final file = File('assets/betterlife_logo.svg');
      expect(
        file.existsSync(),
        isTrue,
        reason:
            'assets/betterlife_logo.svg not found. '
            'Copy it from design_handoff_auth_flow/assets/ before building.',
      );
    });
  });
}
