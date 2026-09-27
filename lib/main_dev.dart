import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/main.dart' as entry;

/// Development environment entry point.
/// Run using: flutter run -t lib/main_dev.dart
Future<void> main() async {
  await entry.main(environment: AppEnvironment.development);
}
