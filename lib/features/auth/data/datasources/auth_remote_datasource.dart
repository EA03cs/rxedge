import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/user_dto.dart';

/// Contract for Remote Authentication Datasource
abstract class AuthRemoteDatasource {
  Future<UserDto> login({
    required String email,
    required String password,
  });

  Future<UserDto> getMe({
    String? currentToken,
    String? currentRefreshToken,
  });

  Future<void> logout({String? refreshToken});
}

/// Real REST implementation of [AuthRemoteDatasource] aligned with `D:\Backend\rxedge\src\modules\Auth`
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasourceImpl(this._dio);

  @override
  Future<UserDto> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.login,
      data: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
    );

    final data = ApiResponseParser.unwrapMap(response.data);
    final rawUser = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : Map<String, dynamic>.from(data);

    rawUser['accessToken'] = data['accessToken'] ?? rawUser['accessToken'] ?? rawUser['token'];
    rawUser['refreshToken'] = data['refreshToken'] ?? rawUser['refreshToken'];

    return UserDto.fromJson(rawUser);
  }

  @override
  Future<UserDto> getMe({
    String? currentToken,
    String? currentRefreshToken,
  }) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.me);
    final data = ApiResponseParser.unwrapMap(response.data);
    final rawUser = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : Map<String, dynamic>.from(data);

    if (currentToken != null && rawUser['accessToken'] == null && rawUser['token'] == null) {
      rawUser['accessToken'] = currentToken;
    }
    if (currentRefreshToken != null && rawUser['refreshToken'] == null) {
      rawUser['refreshToken'] = currentRefreshToken;
    }

    return UserDto.fromJson(rawUser);
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    await _dio.post<dynamic>(
      ApiEndpoints.logout,
      data: <String, dynamic>{
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      },
    );
  }
}
