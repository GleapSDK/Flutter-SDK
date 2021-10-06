package io.gleap.gleap_sdk;

import android.app.Application;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.gleap.APPLICATIONTYPE;
import io.gleap.BugWillBeSentCallback;
import io.gleap.CustomActionCallback;
import io.gleap.GetBitmapCallback;
import io.gleap.Gleap;
import io.gleap.GleapNotInitialisedException;
import io.gleap.GleapSentCallback;
import io.gleap.GleapUserSession;
import io.gleap.RequestType;

public class GleapSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private static Application application;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "gleap_sdk");
        channel.setMethodCallHandler(this);

        application = (Application) flutterPluginBinding.getApplicationContext();
        Gleap.getInstance().setBitmapCallback(new GetBitmapCallback() {
            @Override
            public Bitmap getBitmap() {
                return flutterPluginBinding.getFlutterEngine().getRenderer().getBitmap();
            }
        });
    }

    private void initCustomAction() {
        Gleap.getInstance().setBugWillBeSentCallback(new BugWillBeSentCallback() {
            @Override
            public void flowInvoced() {
                channel.invokeMethod("setBugWillBeSentCallback", null);
            }
        });

        Gleap.getInstance().setBugSentCallback(new GleapSentCallback() {
            @Override
            public void close() {
                channel.invokeMethod("setBugSentCallback", null);
            }
        });

        Gleap.getInstance().registerCustomAction(new CustomActionCallback() {
            @Override
            public void invoke(String message) {
                Map<String, String> map = new HashMap<>();
                map.put("name", message);

                channel.invokeMethod("registerCustomAction", map);
            }
        });
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize":
                Gleap.getInstance().setApplicationType(APPLICATIONTYPE.FLUTTER);
                if (call.argument("gleapUserSession") != null) {
                    try {
                        JSONObject gleapUserData = new JSONObject((Map) call.argument("gleapUserSession"));

                        GleapUserSession gleapUserSession = new GleapUserSession(gleapUserData.getString("userId"),
                                gleapUserData.getString("userHash"), gleapUserData.getString("name"),
                                gleapUserData.getString("email"));
                        Gleap.initialize((String) call.argument("token"), gleapUserSession, application);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    Gleap.initialize((String) call.argument("token"), application);
                }

                initCustomAction();
                result.success(null);
                break;

            case "startFeedbackFlow":
                try {
                    Gleap.getInstance().startFeedbackFlow();
                } catch (GleapNotInitialisedException e) {
                    e.printStackTrace();
                }
                result.success(null);
                break;

            case "sendSilentBugReport":
                Gleap.SEVERITY severity = Gleap.SEVERITY.MEDIUM;
                if (call.argument("severity").equals("LOW")) {
                    severity = Gleap.SEVERITY.LOW;
                } else if (call.argument("severity").equals("MEDIUM")) {
                    severity = Gleap.SEVERITY.MEDIUM;
                } else if (call.argument("severity").equals("HIGH")) {
                    severity = Gleap.SEVERITY.HIGH;
                }

                Gleap.getInstance().sendSilentBugReport("", (String) call.argument("description"), severity);
                result.success(null);
                break;

            case "identifyUserWith":
                GleapUserSession gleapUser = null;
                if (call.argument("gleapUserSession") != null) {
                    try {
                        JSONObject gleapUserData = new JSONObject((Map) call.argument("gleapUserSession"));

                        gleapUser = new GleapUserSession(gleapUserData.getString("userId"),
                                gleapUserData.getString("userHash"), gleapUserData.getString("name"),
                                gleapUserData.getString("email"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                Gleap.getInstance().identifyUser(gleapUser);
                result.success(null);
                break;

            case "clearIdentity":
                Gleap.getInstance().clearIdentity();
                result.success(null);
                break;

            case "setApiUrl":
                Gleap.getInstance().setApiUrl((String) call.argument("apiUrl"));
                result.success(null);
                break;

            case "setWidgetUrl":
                Gleap.getInstance().setWidgetUrl((String) call.argument("widgetUrl"));
                result.success(null);
                break;

            case "setLanguage":
                Gleap.getInstance().setLanguage((String) call.argument("language"));
                result.success(null);
                break;

            case "attachCustomData":
                JSONObject json = new JSONObject((Map) call.argument("customData"));

                Gleap.getInstance().attachCustomData(json);
                result.success(null);
                break;

            case "setCustomData":
                Gleap.getInstance().setCustomData((String) call.argument("key"), (String) call.argument("value"));
                result.success(null);
                break;

            case "removeCustomDataForKey":
                Gleap.getInstance().removeCustomDataForKey((String) call.argument("key"));
                result.success(null);
                break;

            case "clearCustomData":
                Gleap.getInstance().clearCustomData();
                result.success(null);
                break;

            case "logNetwork":
                JSONObject request = new JSONObject((Map) call.argument("request"));
                JSONObject response = new JSONObject((Map) call.argument("response"));

                RequestType requestType;
                switch (call.argument("requestType").toString()) {
                    case "POST":
                        requestType = RequestType.POST;
                        break;

                    case "GET":
                        requestType = RequestType.GET;
                        break;

                    case "DELETE":
                        requestType = RequestType.DELETE;
                        break;

                    case "PUT":
                        requestType = RequestType.PUT;
                        break;

                    case "PATCH":
                        requestType = RequestType.PATCH;
                        break;

                    default:
                        requestType = RequestType.GET;
                }

                Gleap.getInstance().logNetwork((String) call.argument("urlConnection"), requestType,
                        (int) call.argument("status"), (int) call.argument("duration"), request, response);
                result.success(null);
                break;

            case "logEvent":
                JSONObject data = new JSONObject((Map) call.argument("data"));

                Gleap.getInstance().logEvent((String) call.argument("logEvent"), data);
                result.success(null);
                break;

            case "addAttachment":
                Gleap.getInstance().addAttachment((File) call.argument("file"));
                result.success(null);
                break;

            case "removeAllAttachments":
                Gleap.getInstance().removeAllAttachments();
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
