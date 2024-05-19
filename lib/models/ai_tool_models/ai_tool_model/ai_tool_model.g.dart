// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_tool_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AITool _$AIToolFromJson(Map<String, dynamic> json) => AITool(
      name: json['name'] as String,
      description: json['description'] as String,
      response: json['response'] as String,
      executionType: json['executionType'] as String,
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => AIToolParams.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AIToolToJson(AITool instance) => <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'response': instance.response,
      'executionType': instance.executionType,
      'parameters': instance.parameters.map((e) => e.toJson()).toList(),
    };
