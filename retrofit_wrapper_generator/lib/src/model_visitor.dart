import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:code_builder/code_builder.dart';

class ModelVisitor extends SimpleElementVisitor<void> {
  late String className;
  final methods = <(MethodBuilder, String)>[];

  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');
  }

  @override
  void visitMethodElement(MethodElement element) {
    handleVisitMethod(element);
  }

  handleVisitMethod(MethodElement element) {
    final methodBuilder = MethodBuilder()
      ..returns = refer(element.returnType.toString())
      ..name = element.name;
    List<String> paramString = [];

    for (var param in element.parameters) {
      var paramBuilder = ParameterBuilder();
      paramBuilder
        ..type = refer(param.type.toString())
        ..name = param.name;
      if (param.hasDefaultValue) {
        paramBuilder.defaultTo = Code('${param.defaultValueCode}');
      }

      if (param.isNamed) {
        paramBuilder.named = true;
      }
      if (param.isRequiredNamed) {
        paramBuilder.required = true;
      }
      if (param.isNamed) {
        paramString.add('${param.name}: ${param.name}');
      } else {
        paramString.add(param.name);
      }

      if (param.isOptional || param.isRequiredNamed) {
        methodBuilder.optionalParameters.add(paramBuilder.build());
      } else {
        methodBuilder.requiredParameters.add(paramBuilder.build());
      }
    }
    methods.add((methodBuilder, paramString.join(',')));
  }
}
