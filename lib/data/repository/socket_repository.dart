import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/response_state.dart';
import '../../core/constants/api_constants.dart';
import '../../core/providers/app_providers.dart';

class SocketRepository {
  final ApiClient apiClient;

  SocketRepository(this.apiClient);

  /// Upload chat attachment (image)
  Future<ResponseState<dynamic>> chatAttachment({
    required String chatId,
    required String referenceId,
    required String chatType,
    required String imagePath,
  }) async {
    return apiClient.putMultipart<dynamic>(
      SocketApiEndpoint.chatAttachment,
      filePath: imagePath,
      fileFieldName: 'image',
      fields: {
        'chatId': chatId,
        'referenceId': referenceId,
        'chatType': chatType,
      },
    );
  }
}

final socketRepositoryProvider = Provider<SocketRepository>((ref) {
  final apiClient = ref.watch(socketApiClientProvider);
  return SocketRepository(apiClient);
});
