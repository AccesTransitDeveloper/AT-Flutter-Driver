import 'package:driver/data/api/server_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds full URL for relative image paths', () {
    expect(
      ServerConfig.getFullImageUrl('/uploads/user.png'),
      'https://accessibletransit.s3.us-east-1.amazonaws.com/uploads/user.png',
    );
  });

  test('keeps absolute image URLs unchanged', () {
    const absoluteUrl = 'https://cdn.example.com/users/avatar.png';

    expect(
      ServerConfig.getFullImageUrl(absoluteUrl),
      absoluteUrl,
    );
  });
}
