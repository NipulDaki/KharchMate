import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/main.dart' as entry;

/// Staging environment entry point.
/// Run using: flutter run -t lib/main_staging.dart
Future<void> main() async {
  await entry.main(environment: AppEnvironment.staging);
}
