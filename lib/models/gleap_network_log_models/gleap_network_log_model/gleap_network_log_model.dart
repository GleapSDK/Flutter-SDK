import 'package:gleap_sdk/helpers/gleap_network_log_helper.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_request_model/gleap_network_request_model.dart';
import 'package:gleap_sdk/models/gleap_network_log_models/gleap_network_response_model/gleap_network_response_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_log_model.g.dart';

/// One network request, see [Gleap.logNetworkRequest].
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class GleapNetworkLog {
  /// The HTTP method (sent upper case).
  @JsonKey(toJson: _prepareType)
  String? type;

  /// The absolute request url.
  String? url;

  /// When the request started (sent as ISO-8601 UTC with milliseconds).
  @JsonKey(toJson: _prepareDate)
  DateTime? date;

  GleapNetworkRequest? request;

  /// Milliseconds from the request start to the response (or failure).
  /// Sent as an integer.
  @JsonKey(name: 'duration', toJson: _prepareDuration)
  double? duration;

  /// True when an HTTP response arrived (any status), false when the
  /// request failed without one (no connection, timeout, cancelled, ...).
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

String? _prepareType(String? type) {
  return type?.toUpperCase();
}

String? _prepareDate(DateTime? date) {
  if (date == null) {
    return null;
  }

  return GleapNetworkLogHelper.isoDate(date);
}

int _prepareDuration(double? duration) {
  if (duration == null ||
      duration.isNaN ||
      duration.isInfinite ||
      duration < 0) {
    return 0;
  }

  return duration.round();
}
