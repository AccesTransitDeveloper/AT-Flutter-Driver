import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/response_state.dart';
import '../../core/constants/api_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../models/responses/earning/earning_response.dart';
import '../../models/responses/home/heat_map_response.dart';
import '../../models/responses/activity/activity_response.dart';
import '../../models/responses/booking/booking_detail_response.dart';

class HistoryRepository {
  final ApiClient apiClient;

  HistoryRepository(this.apiClient);

  Future<ResponseState<EarningResponse>> getEarning({
    required String startDate,
    required String endDate,
    required bool isGroupByDate,
  }) async {
    return apiClient.get<EarningResponse>(
      ApiEndpoint.earning,
      queryParameters: {
        ApiParams.startDate: startDate,
        ApiParams.endDate: endDate,
        ApiParams.page: '1',
        ApiParams.limit: '1000',
        ApiParams.isGroupByDate: isGroupByDate.toString(),
      },
      fromJsonT: (json) => EarningResponse.fromJson(json),
    );
  }

  Future<ResponseState<HeatMapResponse>> getHeatMap() async {
    return apiClient.get<HeatMapResponse>(
      HistoryApiEndpoint.heatMap,
      fromJsonT: (json) =>
          HeatMapResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<TripBookingHistoryResponse>> getBookingHistory({
    required String startDate,
    required String endDate,
    required int page,
    int limit = 10,
  }) async {
    return apiClient.get<TripBookingHistoryResponse>(
      HistoryApiEndpoint.bookingHistory,
      queryParameters: {
        ApiParams.startDate: startDate,
        ApiParams.endDate: endDate,
        ApiParams.page: page.toString(),
        ApiParams.limit: limit.toString(),
      },
      fromJsonT: (json) =>
          TripBookingHistoryResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ResponseState<BookingDetailResponse>> getBookingHistoryDetail(
      String bookingId) async {
    final path = HistoryApiEndpoint.bookingHistoryDetail
        .replaceAll('{bookingId}', bookingId);
    return apiClient.get<BookingDetailResponse>(
      path,
      fromJsonT: (json) =>
          BookingDetailResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final apiClient = ref.watch(historyApiClientProvider);
  return HistoryRepository(apiClient);
});
