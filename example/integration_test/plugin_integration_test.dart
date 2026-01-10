// // This is a basic Flutter integration test.
// //
// // Since integration tests run in a full Flutter application, they can interact
// // with the host side of a plugin implementation, unlike Dart unit tests.
// //
// // For more information about Flutter integration tests, please see
// // https://flutter.dev/to/integration-testing

// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:flutter_device_state/flutter_device_state.dart';

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   group('VPN Detection Integration Tests', () {
//     testWidgets('checkVpnStatus returns valid state', (
//       WidgetTester tester,
//     ) async {
//       final vpnDetector = VpnDetector();
//       final state = await vpnDetector.checkVpnStatus();

//       // Should return one of the valid states
//       expect(
//         [
//           VpnState.connected,
//           VpnState.disconnected,
//           VpnState.unknown,
//         ].contains(state),
//         true,
//       );
//     });

//     testWidgets('isVpnActive returns boolean', (WidgetTester tester) async {
//       final vpnDetector = VpnDetector();
//       final isActive = await vpnDetector.isVpnActive();

//       // Should return a boolean value
//       expect(isActive, isA<bool>());
//     });

//     testWidgets('vpnStateStream emits values', (WidgetTester tester) async {
//       final vpnDetector = VpnDetector();

//       // Listen to the stream and verify it emits at least one value
//       final state = await vpnDetector.vpnStateStream.first;

//       expect(
//         [
//           VpnState.connected,
//           VpnState.disconnected,
//           VpnState.unknown,
//         ].contains(state),
//         true,
//       );
//     });
//   });
// }
