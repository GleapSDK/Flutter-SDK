import 'package:gleap_sdk/models/ai_tool_models/ai_tool_params_model/ai_tool_params_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_tool_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AITool {
  String name;
  String description;
  String response;
  String executionType;
  List<AIToolParams> parameters;

  AITool({
    required this.name,
    required this.description,
    required this.response,
    required this.executionType,
    required this.parameters,
  });

  factory AITool.fromJson(Map<String, dynamic> json) => _$AIToolFromJson(json);

  Map<String, dynamic> toJson() => _$AIToolToJson(this);
}
