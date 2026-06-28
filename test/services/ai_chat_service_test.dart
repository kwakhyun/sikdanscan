import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sikdanscan/data/services/api_service.dart';
import 'package:sikdanscan/data/services/ai_chat_service.dart';

void main() {
  group('AiChatService', () {
    late AiChatService service;

    setUp(() {
      service = AiChatService();
    });

    test('isConfigured returns false when proxy URL is not set', () {
      expect(service.isConfigured, isFalse);
    });

    test('fallback response for calorie keyword', () async {
      final response = await service.generateResponse(
        userMessage: '오늘 칼로리 얼마나 먹었어?',
      );

      expect(response, contains('칼로리'));
      expect(response, isNotEmpty);
    });

    test('fallback response for exercise keyword', () async {
      final response = await service.generateResponse(userMessage: '운동 추천해줘');

      expect(response, contains('운동'));
    });

    test('fallback response for water keyword', () async {
      final response = await service.generateResponse(
        userMessage: '수분 섭취 팁 알려줘',
      );

      expect(response, contains('수분'));
    });

    test('fallback response for weight keyword', () async {
      final response = await service.generateResponse(userMessage: '체중 변화 분석');

      expect(response, contains('체중'));
    });

    test('fallback response for snack keyword', () async {
      final response = await service.generateResponse(userMessage: '건강한 간식 추천');

      expect(response, contains('간식'));
    });

    test('fallback response for greeting', () async {
      final response = await service.generateResponse(userMessage: '안녕하세요');

      expect(response, contains('안녕'));
    });

    test('fallback response for unknown input', () async {
      final response = await service.generateResponse(
        userMessage: '아무 말이나 해볼게',
      );

      expect(response, isNotEmpty);
      expect(response, contains('식단'));
    });

    test('fallback response supports English locale', () async {
      final response = await service.generateResponse(
        userMessage: 'Analyze today calories',
        locale: 'en',
      );

      expect(response.toLowerCase(), contains('calorie'));
      expect(response, isNot(contains('칼로리')));
    });

    test('generateResponse accepts context parameter', () async {
      final response = await service.generateResponse(
        userMessage: '칼로리 분석해줘',
        context: {
          'todayCalories': 1200,
          'calorieGoal': 1500,
          'currentWeight': 65.0,
          'targetWeight': 58.0,
        },
      );

      expect(response, isNotEmpty);
    });

    test('generateResponse returns assistant content from proxy API', () async {
      final fakeApi = FakeApiService(
        postData: {'content': '오늘은 단백질을 조금 더 보충해보세요.'},
      );
      final service = AiChatService(
        proxyBaseUrl: 'https://proxy.example.com/',
        proxyClientToken: 'client-token',
        apiService: fakeApi,
      );

      final response = await service.generateResponse(
        userMessage: '오늘 식단 어때?',
        locale: 'en',
        context: {
          'todayCalories': 1100,
          'calorieGoal': 1500,
          'macros': {'carbs': '120', 'protein': 45, 'fat': 32.5},
        },
      );

      expect(fakeApi.lastBaseUrl, 'https://proxy.example.com');
      expect(fakeApi.lastPath, '/v1/chat');
      expect(fakeApi.lastHeaders?['Authorization'], 'Bearer client-token');
      expect(fakeApi.lastData, containsPair('locale', 'en'));
      expect(response, '오늘은 단백질을 조금 더 보충해보세요.');
    });

    test(
      'generateResponse falls back when proxy payload is malformed',
      () async {
        final service = AiChatService(
          proxyBaseUrl: 'https://proxy.example.com',
          apiService: FakeApiService(postData: {'content': ''}),
        );

        final response = await service.generateResponse(userMessage: '운동 추천해줘');

        expect(response, contains('운동'));
      },
    );
  });
}

class FakeApiService implements ApiService {
  FakeApiService({this.postData});

  final Object? postData;
  String? lastBaseUrl;
  String? lastPath;
  Map<String, dynamic>? lastHeaders;
  dynamic lastData;

  @override
  Dio get dio => Dio();

  @override
  void close() {}

  @override
  Future<Response<T>> get<T>(
    String baseUrl,
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError('GET is not used by AiChatService tests');
  }

  @override
  Future<Response<T>> post<T>(
    String baseUrl,
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    lastBaseUrl = baseUrl;
    lastPath = path;
    lastHeaders = headers;
    lastData = data;
    return Response<T>(
      data: postData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
    );
  }
}
