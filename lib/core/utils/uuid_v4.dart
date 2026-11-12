import 'dart:math';

/// Cryptographically strong RFC-4122 Version 4 UUID generator
/// used for idempotent offline submission keys (`clientSubmissionId`).
abstract final class UuidV4 {
  static final Random _random = Random.secure();

  static String generate() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx

    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
      buffer.write(hex(bytes[i]));
    }
    return buffer.toString();
  }
}
