import 'package:flutter_test/flutter_test.dart';
import 'package:sikdanscan/data/services/supabase_backend_service.dart';
import 'package:sikdanscan/data/services/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    test('normalizes URL and reports configured state', () {
      final config = SupabaseConfig(
        url: ' https://project.supabase.co/// ',
        publishableKey: ' publishable-key ',
      );

      expect(config.url, 'https://project.supabase.co');
      expect(config.publishableKey, 'publishable-key');
      expect(config.isConfigured, isTrue);
    });

    test('requires both URL and publishable key', () {
      expect(
        SupabaseConfig(url: 'https://project.supabase.co').isConfigured,
        isFalse,
      );
      expect(SupabaseConfig(publishableKey: 'key').isConfigured, isFalse);
    });

    test('reads explicit environment overrides', () {
      final config = SupabaseConfig.fromEnvironment(
        urlOverride: 'https://project.supabase.co',
        publishableKeyOverride: 'publishable-key',
      );

      expect(config.isConfigured, isTrue);
      expect(config.url, 'https://project.supabase.co');
      expect(config.publishableKey, 'publishable-key');
    });
  });

  group('SupabaseBackendService', () {
    test('stays disabled when config is missing', () async {
      final service = SupabaseBackendService(config: SupabaseConfig());

      expect(service.isConfigured, isFalse);
      expect(service.currentUser, isNull);
      await expectLater(
        service.fetchProfile(),
        throwsA(isA<SupabaseNotConfiguredException>()),
      );
    });
  });
}
