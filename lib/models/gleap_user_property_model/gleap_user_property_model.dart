import 'package:json_annotation/json_annotation.dart';

part 'gleap_user_property_model.g.dart';

@JsonSerializable()
class GleapUserProperty {
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? plan;
  String? companyName;
  String? companyId;
  double? value;
  Map<String, dynamic>? customData;

  GleapUserProperty({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.value,
    this.plan,
    this.companyName,
    this.companyId,
    this.customData,
  });

  factory GleapUserProperty.fromJson(Map<String, dynamic> json) =>
      _$GleapUserPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$GleapUserPropertyToJson(this);
}
