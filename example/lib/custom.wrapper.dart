// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom.dart';

// **************************************************************************
// RetrofitWrapperGenerator
// **************************************************************************

class CustomClientWrapper {
  CustomClientWrapper(this.customClient);

  final CustomClient customClient;

  Future<ApiEither<String?>> getVideos() {
    return catchHandler("getVideos", "String?", () => customClient.getVideos());
  }

  Future<ApiEither<dynamic>> getUser(String id) {
    return catchHandler("getUser", "dynamic", () => customClient.getUser(id));
  }

  Future<ApiEither<T>> catchHandler<T>(
    String methodName,
    String type,
    Function callback,
  ) async {
    throw UnimplementedError('sub wrapper class need to implement this method');
  }
}
