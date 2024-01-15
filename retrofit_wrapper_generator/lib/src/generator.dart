import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dart_style/dart_style.dart';
import 'package:retrofit_wrapper_generator/src/model_visitor.dart';
import 'package:source_gen/source_gen.dart';
import 'package:retrofit_wrapper/retrofit_wrapper.dart';
import 'package:code_builder/code_builder.dart';

class RetrofitWrapperGenerator extends GeneratorForAnnotation<Wrapper> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = ModelVisitor();
    // visit mixin
    for (var mixin in (element as ClassElement).mixins) {
      mixin.element.visitChildren(visitor);
    }

    element.visitChildren(visitor);

    String annotatedClassName = visitor.className;
    String wrapperClassName =
        annotation.peek('name')?.stringValue ?? '${annotatedClassName}Wrapper';

    String defaultWrapperReturnClassName = 'WrapperReturnClass';
    String? wrapperReturnClassName;
    DartType? wrapperReturnClass = annotation.peek('returnType')?.typeValue;
    // first check if is typedef alias name
    if (wrapperReturnClass != null) {
      wrapperReturnClassName = wrapperReturnClass.alias?.element.displayName ??
          wrapperReturnClass.getDisplayString(withNullability: false);

      if (wrapperReturnClassName.contains('<')) {
        wrapperReturnClassName = wrapperReturnClassName.substring(
            0, wrapperReturnClassName.indexOf('<'));
      }
    }

    String classFieldName =
        annotatedClassName[0].toLowerCase() + annotatedClassName.substring(1);

    List<Method> methods = [];

    for (var (methodBuilder, paramString) in visitor.methods) {
      String returnTypeIgnoreFuture = methodBuilder.returns!.symbol ?? '';
      bool containsFuture = returnTypeIgnoreFuture.startsWith('Future<');
      if (containsFuture) {
        returnTypeIgnoreFuture = returnTypeIgnoreFuture.substring(
            'Future<'.length, returnTypeIgnoreFuture.length - 1);
      }
      String wrapReturnType = wrapperReturnClassName == null
          ? returnTypeIgnoreFuture
          : '$wrapperReturnClassName<$returnTypeIgnoreFuture>';

      // if (containsFuture) {
      wrapReturnType = 'Future<$wrapReturnType>';
      // }

      methodBuilder.returns = refer(wrapReturnType);

      methodBuilder.body = Code('''
return catchHandler(
        "${methodBuilder.name}", "$returnTypeIgnoreFuture", () => $classFieldName.${methodBuilder.name}($paramString));
''');
      methods.add(methodBuilder.build());
    }
    // catchHandler method: if use default WrapperReturnClass then will add default implement behavior
    String catchHandlerBlock = wrapperReturnClassName != null &&
            wrapperReturnClassName == defaultWrapperReturnClassName
        ? '''
        T result = await callback();
        return $wrapperReturnClassName(result);
    '''
        : "throw UnimplementedError('sub wrapper class need to implement this method');";

    methods.add(Method((b) => b
      ..returns = refer(
          "Future<${wrapperReturnClassName == null ? 'T' : '$wrapperReturnClassName<T>'}>")
      ..name = 'catchHandler<T>'
      ..modifier = MethodModifier.async
      ..requiredParameters.addAll([
        Parameter((b) => b
          ..type = refer('String')
          ..name = 'methodName'),
        Parameter((b) => b
          ..type = refer('String')
          ..name = 'type'),
        Parameter((b) => b
          ..type = refer('Function')
          ..name = 'callback')
      ])
      ..body = Code(catchHandlerBlock)));

    final wrapperClass = Class((b) => b
      ..name = wrapperClassName
      ..fields.add(Field((b) => b
        ..modifier = FieldModifier.final$
        ..type = refer(annotatedClassName)
        ..name = classFieldName))
      ..constructors
          .add(Constructor((b) => b.requiredParameters.add(Parameter((b) => b
            ..toThis = true
            ..name = classFieldName))))
      ..methods.addAll(methods));

    final librayClass = Library((b) => b.body.addAll([wrapperClass]));

    final emitter = DartEmitter();
    return DartFormatter().format('${librayClass.accept(emitter)}');
  }
}
