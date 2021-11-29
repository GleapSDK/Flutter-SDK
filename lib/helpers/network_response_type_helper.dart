class NetworkResponseTypeHelper {
  static String getType({required dynamic data}) {
    if (data is String ||
        data is Map<String, dynamic> ||
        data is List ||
        data == null) {
      return data.toString();
    }

    return '<response_type_not_supported>';
  }
}
