import 'package:gleap_sdk/helpers/gleap_network_log_helper.dart';

class NetworkResponseTypeHelper {
  /// Converts a response body to text: Strings are kept, Maps and Lists are
  /// JSON-encoded (not Dart's `{a: b}` syntax), bytes and streams become
  /// markers. See [GleapNetworkLogHelper.stringifyBody].
  static String getType({required dynamic data}) {
    return GleapNetworkLogHelper.stringifyBody(data);
  }
}
