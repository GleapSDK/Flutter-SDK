import 'package:json_annotation/json_annotation.dart';

part 'ai_tool_params_model.g.dart';

enum AIParamType { STRING, NUMBER, BOOLEAN }

String _getAIParamTypeValue(AIParamType paramType) {
  switch (paramType) {
    case AIParamType.STRING:
      return "string";
    case AIParamType.NUMBER:
      return "number";
    case AIParamType.BOOLEAN:
      return "boolean";
    default:
      return "string";
  }
}

AIParamType _getAIParamTypeEnum(String paramType) {
  switch (paramType) {
    case "string":
      return AIParamType.STRING;
    case "number":
      return AIParamType.NUMBER;
    case "boolean":
      return AIParamType.BOOLEAN;
    default:
      return AIParamType.STRING;
  }
}

@JsonSerializable()
class AIToolParams {
  String name;
  String description;
  @JsonKey(
    name: "type",
    toJson: _getAIParamTypeValue,
    fromJson: _getAIParamTypeEnum,
  )
  AIParamType type;
  bool required;
  List<String>? enums;

  AIToolParams({
    required this.name,
    required this.description,
    required this.type,
    required this.required,
    this.enums,
  });

  factory AIToolParams.fromJson(Map<String, dynamic> json) =>
      _$AIToolParamsFromJson(json);

  Map<String, dynamic> toJson() => _$AIToolParamsToJson(this);
}
