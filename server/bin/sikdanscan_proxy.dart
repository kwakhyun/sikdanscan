// ignore_for_file: avoid_relative_lib_imports

import 'dart:async';
import 'dart:io';

import '../lib/src/proxy_config.dart';
import '../lib/src/proxy_env_loader.dart';
import '../lib/src/proxy_handlers.dart';

Future<void> main(List<String> args) async {
  final config = ProxyConfig.fromEnvironment(
    loadProxyEnvironment(Platform.environment),
  );
  await config.database.open();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, config.port);

  stdout.writeln(
    '식단스캔 proxy listening on http://${server.address.host}:${server.port}',
  );
  config.logger.startup(
    port: config.port,
    database: config.database.description,
  );

  var isShuttingDown = false;
  Future<void> shutdown(ProcessSignal signal) async {
    if (isShuttingDown) return;
    isShuttingDown = true;
    stdout.writeln('Received ${signal.toString()}, shutting down.');
    await server.close(force: false);
  }

  final signalSubscriptions = <StreamSubscription<ProcessSignal>>[
    ProcessSignal.sigint.watch().listen((signal) {
      unawaited(shutdown(signal));
    }),
    if (!Platform.isWindows)
      ProcessSignal.sigterm.watch().listen((signal) {
        unawaited(shutdown(signal));
      }),
  ];

  try {
    await serveRequests(server, config);
  } finally {
    for (final subscription in signalSubscriptions) {
      await subscription.cancel();
    }
  }
}
