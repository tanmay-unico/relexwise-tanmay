import 'package:dio/dio.dart';

String mapErrorToMessage(Object error) {
  if (error is DioException) {
    final res = error.response;
    final status = res?.statusCode ?? 0;
    switch (status) {
      case 0:
        return 'Unable to reach server. Check your internet connection.';
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Incorrect email or password. Please try again.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'Requested resource was not found.';
      case 409:
        return 'This action conflicts with an existing record.';
      case 422:
        return 'Some fields are invalid. Please review and try again.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server is having trouble. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  if (error is FormatException) {
    return 'Received an unexpected response. Please try again later.';
  }
  return 'Something went wrong. Please try again.';
}


