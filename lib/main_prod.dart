import 'package:kharch_mate/environment/app_environment.dart';
import 'package:kharch_mate/main.dart' as entry;

/// Production environment entry point.
/// Run using: flutter run -t lib/main_prod.dart
Future<void> main() async {
  await entry.main(environment: AppEnvironment.production);
}
