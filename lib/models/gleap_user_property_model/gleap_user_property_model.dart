import 'package:json_annotation/json_annotation.dart';

part 'gleap_user_property_model.g.dart';

@JsonSerializable()
class GleapUserProperty {
  String? userId;
  String? name;
  String? email;
  String? phone;
  double? value;

  GleapUserProperty({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.value,
  });

  factory GleapUserProperty.fromJson(Map<String, dynamic> json) =>
      _$GleapUserPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$GleapUserPropertyToJson(this);
}
