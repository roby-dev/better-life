import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:better_life_app/features/habits/data/datasources/habit_remote_data_source.dart';
import 'package:better_life_app/features/habits/data/dtos/upsert_habit_request_dto.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DioHabitRemoteDataSource sut;

  const baseUrl = 'http://localhost';
  const habitsPath = '/api/v1/habits';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = DioAdapter(dio: dio);
    sut = DioHabitRemoteDataSource(dio);
  });

  group('DioHabitRemoteDataSource.getHabits', () {
    test('returns list of HabitDto on 200', () async {
      adapter.onGet(
        habitsPath,
        (server) => server.reply(200, [
          {
            'id': 'h1',
            'userId': 'u1',
            'categoryId': 'c1',
            'name': 'Run',
            'frequencyType': 0,
            'weekDays': 0,
            'reminderTime': null,
            'status': 0,
            'createdAt': '2026-01-01T00:00:00Z',
            'updatedAt': '2026-01-01T00:00:00Z',
          },
        ]),
      );

      final result = await sut.getHabits();

      expect(result.length, 1);
      expect(result.first.name, 'Run');
      expect(result.first.frequencyType, 0);
    });

    test('throws DioException on 401', () async {
      adapter.onGet(
        habitsPath,
        (server) => server.reply(401, {'title': 'Unauthorized'}),
      );

      expect(
        () => sut.getHabits(),
        throwsA(isA<DioException>()),
      );
    });

    test('throws DioException on 500', () async {
      adapter.onGet(
        habitsPath,
        (server) => server.reply(500, {'title': 'Server Error'}),
      );

      expect(
        () => sut.getHabits(),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('DioHabitRemoteDataSource.upsertHabit', () {
    test('returns HabitDto on 200', () async {
      final request = UpsertHabitRequestDto(
        name: 'Read',
        categoryId: 'c1',
        frequencyType: 0,
        weekDays: 0,
        reminderTime: null,
      );

      adapter.onPost(
        habitsPath,
        (server) => server.reply(200, {
          'id': 'h1',
          'userId': 'u1',
          'categoryId': 'c1',
          'name': 'Read',
          'frequencyType': 0,
          'weekDays': 0,
          'reminderTime': null,
          'status': 0,
          'createdAt': '2026-01-01T00:00:00Z',
          'updatedAt': '2026-01-01T00:00:00Z',
        }),
        data: request.toJson(),
      );

      final result = await sut.upsertHabit(request);

      expect(result.id, 'h1');
      expect(result.name, 'Read');
    });

    test('throws DioException on 500', () async {
      final request = UpsertHabitRequestDto(
        name: 'Read',
        categoryId: 'c1',
        frequencyType: 0,
        weekDays: 0,
      );

      adapter.onPost(
        habitsPath,
        (server) => server.reply(500, {'title': 'Server Error'}),
        data: request.toJson(),
      );

      expect(
        () => sut.upsertHabit(request),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('DioHabitRemoteDataSource.deleteHabit', () {
    test('completes on 204', () async {
      adapter.onDelete(
        '$habitsPath/h1',
        (server) => server.reply(204, null),
      );

      await sut.deleteHabit('h1');

      // no exception = success
    });

    test('throws DioException on 404', () async {
      adapter.onDelete(
        '$habitsPath/h1',
        (server) => server.reply(404, {'title': 'Not Found'}),
      );

      expect(
        () => sut.deleteHabit('h1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
