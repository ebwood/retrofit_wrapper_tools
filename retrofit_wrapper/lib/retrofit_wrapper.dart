import 'package:meta/meta.dart';

@immutable
class Wrapper {
  // default wrapper class: {ClassName}Wrapper
  final String? name;
  // default return class: WrapperReturnClass
  // if use default WrapperReturnClass then WrapperClass.catchHandler will add default implement behavior
  final Type? returnType;
  const Wrapper({
    this.name,
    this.returnType = WrapperReturnClass,
  });
}

const wrapper = Wrapper();

class WrapperReturnClass<T> {
  final T result;
  WrapperReturnClass(this.result);
}
