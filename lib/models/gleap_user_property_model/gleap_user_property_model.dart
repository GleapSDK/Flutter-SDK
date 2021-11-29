import 'package:json_annotation/json_annotation.dart';

part 'gleap_user_property_model.g.dart';

@JsonSerializable()
class GleapUserProperty {
  String? name;
  String? email;

  GleapUserProperty({
    this.name,
    this.email,
  });

  factory GleapUserProperty.fromJson(Map<String, dynamic> json) =>
      _$GleapUserPropertyFromJson(json);

  Map<String, dynamic> toJson() => _$GleapUserPropertyToJson(this);
}
