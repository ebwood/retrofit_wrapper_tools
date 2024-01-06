import 'package:dio/dio.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit_wrapper/retrofit_wrapper.dart';

part 'simple.g.dart';
part 'simple.wrapper.dart';

@RestApi(baseUrl: "https://example.com")
@wrapper
abstract class SimpleClient {
  factory SimpleClient(Dio dio, {String baseUrl}) = _SimpleClient;

  @GET('/user/{id}')
  Future getUser(@Path() String id);
}
