import 'package:json_annotation/json_annotation.dart';

part 'gleap_user_property_model.g.dart';

@JsonSerializable(includeIfNull: false)
class GleapUserProperty {
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? plan;
  String? companyName;
  String? companyId;
  String? avatar;
  String? lang;
  double? value;
  double? sla;
  Map<String, dynamic>? customData;

  GleapUserProperty({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.value,
    this.plan,
    this.companyName,
    this.avatar,
    this.companyId,
    this.lang,
    this.sla,
    this.customData,
  });

  factory GleapUserProperty.fromJson(Map<String, dynamic> json) =>
      _$GleapUserPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$GleapUserPropertyToJson(this);
}
