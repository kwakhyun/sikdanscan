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

    test('English fallback matches whole words only', () async {
      final response = await service.generateResponse(
        userMessage: 'Is this healthy?',
        locale: 'en',
      );

      expect(response, isNot(startsWith('Hi.')));
    });

    test('reply marks local answers as fallback', () async {
      final reply = await service.reply(userMessage: '운동 추천해줘');

      expect(reply.isFallback, isTrue);
      expect(reply.content, contains('운동'));
    });

    test('reply sends trimmed conversation history to the proxy', () async {
      final fakeApi = FakeApiService(postData: {'content': '좋아요'});
      final service = AiChatService(
        proxyBaseUrl: 'https://proxy.example.com',
        apiService: fakeApi,
      );
      final history = [
        for (var i = 0; i < 14; i++)
          AiChatTurn(isUser: i.isEven, content: 'turn $i'),
      ];

      final reply = await service.reply(
        userMessage: '그럼 저녁은?',
        history: history,
      );

      expect(reply.isFallback, isFalse);
      final sent = (fakeApi.lastData as Map)['history'] as List;
      expect(sent, hasLength(AiChatService.maxHistoryTurns));
      expect(sent.first, {'role': 'user', 'content': 'turn 4'});
      expect(sent.last, {'role': 'assistant', 'content': 'turn 13'});
    });

    test('a slow answer is a retryable error, not offline', () async {
      final service = AiChatService(
        proxyBaseUrl: 'https://proxy.example.com',
        apiService: FakeApiService(
          postError: DioException(
            requestOptions: RequestOptions(path: '/v1/chat'),
            type: DioExceptionType.receiveTimeout,
            error: ApiError(message: 'timeout', code: 'TIMEOUT'),
          ),
        ),
      );

      await expectLater(
        service.reply(userMessage: 'hi'),
        throwsA(isA<DioException>()),
      );
    });

    test('an unreachable server answers with offline tips', () async {
      final service = AiChatService(
        proxyBaseUrl: 'https://proxy.example.com',
        apiService: FakeApiService(
          postError: DioException(
            requestOptions: RequestOptions(path: '/v1/chat'),
            type: DioExceptionType.connectionError,
            error: ApiError(message: 'offline', code: 'NO_CONNECTION'),
          ),
        ),
      );

      final reply = await service.reply(userMessage: '운동 추천해줘');
      expect(reply.isFallback, isTrue);
      expect(reply.quotaExceeded, isFalse);
    });

    test(
      'chat retries once, waits past the proxy timeout and caps length',
      () async {
        final fakeApi = FakeApiService(postData: {'content': 'ok'});
        final service = AiChatService(
          proxyBaseUrl: 'https://proxy.example.com',
          apiService: fakeApi,
        );

        await service.reply(userMessage: 'a' * 5000);

        expect(fakeApi.lastMaxRetries, 1);
        expect(fakeApi.lastReceiveTimeout, AiChatService.chatReceiveTimeout);
        expect(
          ((fakeApi.lastData as Map)['message'] as String).length,
          AiChatService.maxMessageLength,
        );
      },
    );

    test('reply throws on server errors so the UI can offer retry', () async {
      final service = AiChatService(
        proxyBaseUrl: 'https://proxy.example.com',
        apiService: FakeApiService(postData: {'content': ''}),
      );

      await expectLater(
        service.reply(userMessage: 'hi'),
        throwsA(isA<AiChatException>()),
      );
    });
  });
}

class FakeApiService implements ApiService {
  FakeApiService({this.postData, this.postError});

  final Object? postData;
  final Object? postError;
  String? lastBaseUrl;
  String? lastPath;
  Map<String, dynamic>? lastHeaders;
  dynamic lastData;
  int? lastMaxRetries;
  Duration? lastReceiveTimeout;

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
    CancelToken? cancelToken,
    int? maxRetries,
    Duration? receiveTimeout,
  }) async {
    lastBaseUrl = baseUrl;
    lastPath = path;
    lastHeaders = headers;
    lastData = data;
    lastMaxRetries = maxRetries;
    lastReceiveTimeout = receiveTimeout;
    final error = postError;
    if (error != null) throw error;
    return Response<T>(
      data: postData as T?,
      requestOptions: RequestOptions(path: '$baseUrl$path'),
    );
  }
}
