// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import '../lib/src/proxy_config.dart';
import '../lib/src/proxy_env_loader.dart';
import '../lib/src/proxy_handlers.dart';

Future<void> main(List<String> args) async {
  final config = ProxyConfig.fromEnvironment(
    loadProxyEnvironment(Platform.environment),
  );
  final server = await HttpServer.bind(InternetAddress.anyIPv4, config.port);

  stdout.writeln(
    '식단스캔 proxy listening on http://${server.address.host}:${server.port}',
  );

  await serveRequests(server, config);
}
