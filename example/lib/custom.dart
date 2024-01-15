library custom;

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit_wrapper/retrofit_wrapper.dart';

part 'mixin.dart';
part 'custom.g.dart';
part 'custom.wrapper.dart';

@RestApi(baseUrl: "https://example.com")
@Wrapper(returnType: ApiEither, )
abstract class CustomClient with VideoMixin {
  factory CustomClient(Dio dio, {String baseUrl}) = _CustomClient;

  @GET('/user/{id}')
  Future getUser(@Path() String id);
}

class ApiException implements Exception {
  dynamic error;
  ApiException(this.error);
}

typedef ApiEither<T> = Either<ApiException, T>;

class ApiService extends CustomClientWrapper {
  ApiService(super.customClient);

  @override
  Future<ApiEither<T>> catchHandler<T>(
      String methodName, String type, Function callback) async {
    try {
      T result = await callback();
      return right(result);
    } catch (e) {
      return left(ApiException(e));
    }
  }
}
