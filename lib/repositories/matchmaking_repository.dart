import 'package:dio/dio.dart';
import 'package:muscle_rivals/constants.dart';

class MatchmakingRepository {
  final Dio _dio;
  MatchmakingRepository({required Dio dio}) : _dio = dio;

  Future<void> queueIntoMatchmaking() {
    return _dio
        .post("${Constants.BASE_API_URL}/matchmaking/queue")
        .timeout(const Duration(seconds: 10));
  }
}
