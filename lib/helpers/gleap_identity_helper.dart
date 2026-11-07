import 'dart:async';

import 'package:gleap_sdk/models/gleap_user_property_model/gleap_user_property_model.dart';

/// Fetches a fresh identity token (JWT) from your backend; see
/// `Gleap.setUserJwtProvider`. Return `null` (or throw) when that failed.
typedef GleapUserJwtProvider = FutureOr<String?> Function();

/// The Project ID passed to `Gleap.initialize`: [projectId], or the former
/// name [token] (same value). `null` when neither is set.
String? gleapResolveProjectId({String? projectId, String? token}) {
  if (projectId != null && projectId.isNotEmpty) {
    return projectId;
  }
  if (token != null && token.isNotEmpty) {
    return token;
  }
  return null;
}

/// The method channel arguments of `initialize`. The Project ID goes under
/// both names: the native plugins read `projectId` and fall back to `token`.
Map<String, dynamic> gleapInitializeArguments(String projectId) {
  return <String, dynamic>{
    'projectId': projectId,
    'token': projectId,
  };
}

/// The method channel arguments of an identify. The user hash (a legacy hash
/// or an identity token) is sent with or without user properties.
Map<String, dynamic> gleapIdentifyArguments({
  required String userId,
  GleapUserProperty? userProperties,
  String? userHash,
}) {
  return <String, dynamic>{
    'userId': userId,
    if (userProperties != null) 'userProperties': userProperties.toJson(),
    if (userHash != null) 'userHash': userHash,
  };
}

/// Answers the native SDK's token request (`requestUserJwt`) with the
/// provider's token, or `null` without a provider, on an error or without a
/// token. The native SDK keeps the rules (one call at a time, 10 s timeout,
/// 30 s pause after a failure).
Future<String?> gleapAnswerUserJwtRequest(GleapUserJwtProvider? provider) async {
  if (provider == null) {
    return null;
  }
  try {
    final String? token = await provider();
    return token != null && token.isNotEmpty ? token : null;
  } catch (_) {
    return null;
  }
}
