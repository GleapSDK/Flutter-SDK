import 'package:json_annotation/json_annotation.dart';

part 'gleap_user_property_model.g.dart';

@JsonSerializable()
class GleapUserProperty {
  String? name;
  String? email;
  double? value;

  GleapUserProperty({
    this.name,
    this.email,
    this.value,
  });

  factory GleapUserProperty.fromJson(Map<String, dynamic> json) =>
      _$GleapUserPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$GleapUserPropertyToJson(this);
}
