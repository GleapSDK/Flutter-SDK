// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tool_params_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIToolParams _$AIToolParamsFromJson(Map<String, dynamic> json) => AIToolParams(
      name: json['name'] as String,
      description: json['description'] as String,
      type: _getAIParamTypeEnum(json['type'] as String),
      required: json['required'] as bool,
      enums:
          (json['enums'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AIToolParamsToJson(AIToolParams instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'type': _getAIParamTypeValue(instance.type),
      'required': instance.required,
      'enums': instance.enums,
    };
