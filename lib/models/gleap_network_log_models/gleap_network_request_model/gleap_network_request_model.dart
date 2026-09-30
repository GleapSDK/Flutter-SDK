import 'package:gleap_sdk/helpers/gleap_network_log_helper.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gleap_network_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class GleapNetworkRequest {
  /// The request body. Strings are sent as they are, Maps and Lists are
  /// JSON-encoded, bytes become `[binary body omitted]`. Capped at 150 KB.
  @JsonKey(name: 'payload', toJson: _preparePayload)
  dynamic payload;

  /// The request headers. Values are sent as strings, lists are joined
  /// with ", ".
  @JsonKey(toJson: _prepareHeaders)
  Map<String, dynamic>? headers;

  GleapNetworkRequest({this.payload, this.headers});

  factory GleapNetworkRequest.fromJson(Map<String, dynamic> json) =>
      _$GleapNetworkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GleapNetworkRequestToJson(this);
}

String _preparePayload(dynamic payload) {
  try {
    return GleapNetworkLogHelper.capBody(
      GleapNetworkLogHelper.stringifyBody(payload),
    );
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
