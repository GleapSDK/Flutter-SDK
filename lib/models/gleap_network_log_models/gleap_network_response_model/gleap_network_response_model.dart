import 'package:gleap_sdk/helpers/gleap_network_log_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_response_model.g.dart';

/// The response of a logged request. For a request that failed without an
/// HTTP response, set only [errorText] (and no [status]).
@JsonSerializable(includeIfNull: false)
class GleapNetworkResponse {
  int? status;
  String? statusText;

  /// The response headers. Values are sent as strings, lists are joined
  /// with ", ".
  @JsonKey(toJson: _prepareHeaders)
  Map<String, dynamic>? headers;

  /// The response body as text, capped at 150 KB.
  @JsonKey(name: 'responseText', toJson: _prepareResponse)
  String? responseText;

  /// A human readable error for requests that failed without a response.
  String? errorText;

  GleapNetworkResponse({
    this.status,
    this.statusText,
    this.responseText,
    this.headers,
    this.errorText,
  });

  factory GleapNetworkResponse.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkResponseToJson(this);
}

String? _prepareResponse(String? responseText) {
  try {
    if (responseText == null) {
      return null;
    }

    return GleapNetworkLogHelper.capBody(responseText);
  } catch (_) {
    return '';
  }
}

Map<String, String>? _prepareHeaders(Map<String, dynamic>? headers) {
  try {
    return GleapNetworkLogHelper.prepareHeaders(headers);
  } catch (_) {
    return null;
  }
}
