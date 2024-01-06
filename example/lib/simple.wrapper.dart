// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple.dart';

// **************************************************************************
// RetrofitWrapperGenerator
// **************************************************************************

class SimpleClientWrapper {
  SimpleClientWrapper(this.simpleClient);

  final SimpleClient simpleClient;

  Future<WrapperReturnClass<dynamic>> getUser(String id) {
    return catchHandler("getUser", "dynamic", () => simpleClient.getUser(id));
  }

  Future<WrapperReturnClass<T>> catchHandler<T>(
    String methodName,
    String type,
    Function callback,
  ) async {
    T result = await callback();
    return WrapperReturnClass(result);
  }
}
