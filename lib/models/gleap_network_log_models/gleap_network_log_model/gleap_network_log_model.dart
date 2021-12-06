import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_request_model/gleap_network_request_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_response_model/gleap_network_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_log_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GleapNetworkLog {
  String? type;
  String? url;
  DateTime? date;
  GleapNetworkRequest? request;
  @JsonKey(name: 'duration', toJson: _prepareDuration)
  double? duration;
  bool? success;
  GleapNetworkResponse? response;

  GleapNetworkLog({
    this.type,
    this.url,
    this.date,
    this.request,
    this.duration,
    this.success,
    this.response,
  });

  factory GleapNetworkLog.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkLogFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkLogToJson(this);
}

double _prepareDuration(double? duration) {
  if (duration == null) {
    return 0;
  }

  return duration;
}
