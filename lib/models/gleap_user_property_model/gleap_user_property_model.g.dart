// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gleap_user_property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GleapUserProperty _$GleapUserPropertyFromJson(Map<String, dynamic> json) =>
    GleapUserProperty(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      plan: json['plan'] as String?,
      companyName: json['companyName'] as String?,
      companyId: json['companyId'] as String?,
      sla: (json['sla'] as num?)?.toDouble(),
      customData: json['customData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$GleapUserPropertyToJson(GleapUserProperty instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userId', instance.userId);
  writeNotNull('name', instance.name);
  writeNotNull('email', instance.email);
  writeNotNull('phone', instance.phone);
  writeNotNull('plan', instance.plan);
  writeNotNull('companyName', instance.companyName);
  writeNotNull('companyId', instance.companyId);
  writeNotNull('value', instance.value);
  writeNotNull('sla', instance.sla);
  writeNotNull('customData', instance.customData);
  return val;
}
