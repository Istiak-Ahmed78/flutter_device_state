import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_device_state_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('flutter_device_state/vpn');
  const eventChannel = EventChannel('flutter_device_state/vpn_state');
  const codec = StandardMethodCodec();

  setUp(() {
    // Mock MethodChannel (checkVpnStatus)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (MethodCall methodCall) async {
          if (methodCall.method == 'checkVpnStatus') {
            return false; // VPN disconnected
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);

    // Clear event channel handler too (safe even if not set)
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(eventChannel.name, null);
  });

  testWidgets('App displays VPN status', (WidgetTester tester) async {
    // Mock EventChannel using tester.binding messenger (non-deprecated)
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      eventChannel.name,
      (ByteData? message) async {
        final methodCall = codec.decodeMethodCall(message);

        if (methodCall.method == 'listen') {
          // Send an event "false" to the stream
          final event = codec.encodeSuccessEnvelope(false);

          Future.microtask(() {
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              eventChannel.name,
              event,
              (ByteData? _) {},
            );
          });

          // Reply to 'listen'
          return codec.encodeSuccessEnvelope(null);
        }

        if (methodCall.method == 'cancel') {
          return codec.encodeSuccessEnvelope(null);
        }

        return null;
      },
    );

    await tester.pumpWidget(const MyApp());

    expect(find.text('VPN Status'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('VPN is disconnected'), findsOneWidget);
  });

  testWidgets('Check Again button works', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      eventChannel.name,
      (ByteData? message) async {
        final methodCall = codec.decodeMethodCall(message);

        if (methodCall.method == 'listen') {
          final event = codec.encodeSuccessEnvelope(false);

          Future.microtask(() {
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              eventChannel.name,
              event,
              (ByteData? _) {},
            );
          });

          return codec.encodeSuccessEnvelope(null);
        }

        if (methodCall.method == 'cancel') {
          return codec.encodeSuccessEnvelope(null);
        }

        return null;
      },
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('VPN is disconnected'), findsOneWidget);

    final button = find.text('Check Again');
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.text('VPN is disconnected'), findsOneWidget);
  });

  testWidgets('Status icon displays correctly', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      eventChannel.name,
      (ByteData? message) async {
        final methodCall = codec.decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          final event = codec.encodeSuccessEnvelope(false);
          Future.microtask(() {
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              eventChannel.name,
              event,
              (ByteData? _) {},
            );
          });
          return codec.encodeSuccessEnvelope(null);
        }
        if (methodCall.method == 'cancel') {
          return codec.encodeSuccessEnvelope(null);
        }
        return null;
      },
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final iconFinder = find.byWidgetPredicate((widget) => widget is Icon);
    expect(iconFinder, findsWidgets);
  });

  testWidgets('Status card shows all states', (WidgetTester tester) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      eventChannel.name,
      (ByteData? message) async {
        final methodCall = codec.decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          final event = codec.encodeSuccessEnvelope(false);
          Future.microtask(() {
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              eventChannel.name,
              event,
              (ByteData? _) {},
            );
          });
          return codec.encodeSuccessEnvelope(null);
        }
        if (methodCall.method == 'cancel') {
          return codec.encodeSuccessEnvelope(null);
        }
        return null;
      },
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Unknown'), findsOneWidget);
  });

  testWidgets('Real-time monitoring text is shown', (
    WidgetTester tester,
  ) async {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      eventChannel.name,
      (ByteData? message) async {
        final methodCall = codec.decodeMethodCall(message);
        if (methodCall.method == 'listen') {
          final event = codec.encodeSuccessEnvelope(false);
          Future.microtask(() {
            tester.binding.defaultBinaryMessenger.handlePlatformMessage(
              eventChannel.name,
              event,
              (ByteData? _) {},
            );
          });
          return codec.encodeSuccessEnvelope(null);
        }
        if (methodCall.method == 'cancel') {
          return codec.encodeSuccessEnvelope(null);
        }
        return null;
      },
    );

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Real-time monitoring is active'), findsOneWidget);
  });
}
