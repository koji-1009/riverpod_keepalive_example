// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example keepAlive'),
      ),
      body: Center(
        child: Column(
          spacing: 16,
          children: [
            FilledButton(
              onPressed: () async {
                print('readAndKeepAlive:Button: started');
                final value = await ref.read(
                  readAndKeepAliveProvider.future,
                );
                print('readAndKeepAlive:Button: finished: $value');
              },
              child: const Text('Read readAndKeepAlive'),
            ),
            FilledButton.tonal(
              onPressed: () async {
                print('readAndFailedKeepAlive:Button: started');
                final value = await ref.read(
                  readAndFailedKeepAliveProvider.future,
                );
                print('readAndFailedKeepAlive:Button: finished: $value');
              },
              child: const Text('Read readAndFailedKeepAlive'),
            ),
          ],
        ),
      ),
    );
  }
}

const keepDuration = Duration(
  seconds: 10,
);

Future<String> computeValue(String value) async {
  print('computeValue: Started');
  await Future.delayed(
    const Duration(
      seconds: 5,
    ),
  );
  print('computeValue: Finished');
  return value;
}

@riverpod
Future<String> readAndKeepAlive(Ref ref) async {
  print('readAndKeepAlive:Provider: Started');
  ref
    ..onCancel(() {
      print('readAndKeepAlive:Provider: Canceled');
    })
    ..onResume(() {
      print('readAndKeepAlive:Provider: Resumed');
    })
    ..onDispose(() {
      print('readAndKeepAlive:Provider: Disposed');
    });

  final link = ref.keepAlive();
  final String result;
  try {
    result = await computeValue('Read and keep alive');
    print('readAndKeepAlive:Provider: Get result');
  } on Exception catch (_) {
    link.close();
    rethrow;
  }

  print('readAndKeepAlive:Provider: Finished');
  return result;
}

@riverpod
Future<String> readAndFailedKeepAlive(Ref ref) async {
  print('readAndFailedKeepAlive:Provider: Started');
  ref
    ..onCancel(() {
      print('readAndFailedKeepAlive:Provider: Canceled');
    })
    ..onResume(() {
      print('readAndFailedKeepAlive:Provider: Resumed');
    })
    ..onDispose(() {
      print('readAndFailedKeepAlive:Provider: Disposed');
    });

  final result = await computeValue('Read and failed keep alive');
  print('readAndFailedKeepAlive:Provider: Get result');

  ref.keepAlive();

  print('readAndFailedKeepAlive:Provider: Finished');
  return result;
}
