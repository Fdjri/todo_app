import 'package:uuid/uuid.dart';

/// UUID generator utility
class IdGenerator {
  static const _uuid = Uuid();

  IdGenerator._();

  static String generate() => _uuid.v4();
}
