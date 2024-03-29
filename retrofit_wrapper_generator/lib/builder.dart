import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/generator.dart';

Builder retrofitWrapperBuilder(BuilderOptions options) =>
    PartBuilder([RetrofitWrapperGenerator()], '.wrapper.dart');
