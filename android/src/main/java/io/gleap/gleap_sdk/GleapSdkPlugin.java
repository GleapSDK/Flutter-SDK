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

        /*
         * Gleap.getInstance().setBitmapCallback(new GetBitmapCallback() {
         * 
         * @Override public Bitmap getBitmap() {
         * channel.invokeMethod("setBitmapCallback", null); return
         * Bitmap.createBitmap('sdf'); } });
         * 
         */

        Gleap.getInstance().registerCustomAction(new CustomActionCallback() {
            @Override
            public void invoke(String message) {
                Map<String, String> map = new HashMap<>();
                map.put("name", message);

                channel.invokeMethod("registerCustomAction", map);
            }
        });

        /*
         * Gleap.getInstance().registerCustomAction(new CustomActionCallback() {
         * 
         * @Override public void invoke(final String message) {
         * 
         * uiThreadHandler.post(new Runnable() {
         * 
         * @Override public void run() {
         * 
         * Map<String, String> map = new HashMap<>(); map.put("name", message);
         * 
         * System.out.println(map.get("name"));
         * channel.invokeMethod("customActionCalled", map); } }); } });
         * 
         */
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize":
                Gleap.getInstance().setApplicationType(APPLICATIONTYPE.FLUTTER);
                GleapUserSession gleapUserSession = null;
                if (call.argument("gleapUserSession") != null) {
                    try {
                        gleapUserSession = new GleapUserSession(
                                ((JSONObject) call.argument("gleapUserSession")).getString("userId"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("userHash"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("name"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("email"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                if (gleapUserSession != null) {
                    Gleap.initialize((String) call.argument("token"), gleapUserSession, application);
                } else {
                    Gleap.initialize((String) call.argument("token"), application);
                }
                initCustomAction();
                break;

            case "startFeedbackFlow":
                try {
                    Gleap.getInstance().startFeedbackFlow();
                } catch (GleapNotInitialisedException e) {
                    e.printStackTrace();
                }
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
                break;

            case "identifyUserWith":
                GleapUserSession gleapUser = null;
                if (call.argument("gleapUserSession") != null) {
                    try {
                        gleapUser = new GleapUserSession(
                                ((JSONObject) call.argument("gleapUserSession")).getString("userId"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("userHash"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("name"),
                                ((JSONObject) call.argument("gleapUserSession")).getString("email"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                Gleap.getInstance().identifyUser(gleapUser);
                break;

            case "clearIdentity":
                Gleap.getInstance().clearIdentity();
                break;

            case "setApiUrl":
                Gleap.getInstance().setApiUrl((String) call.argument("apiUrl"));
                break;

            case "setWidgetUrl":
                Gleap.getInstance().setWidgetUrl((String) call.argument("widgetUrl"));
                break;

            case "setLanguage":
                Gleap.getInstance().setLanguage((String) call.argument("language"));
                break;

            case "attachCustomData":
                Gleap.getInstance().attachCustomData((JSONObject) call.argument("customData"));
                break;

            case "setCustomData":
                Gleap.getInstance().setCustomData((String) call.argument("key"), (String) call.argument("value"));
                break;

            case "removeCustomDataForKey":
                Gleap.getInstance().removeCustomDataForKey((String) call.argument("key"));
                break;

            case "clearCustomData":
                Gleap.getInstance().clearCustomData();
                break;

            case "logNetwork":
                Gleap.getInstance().logNetwork((String) call.argument("urlConnection"),
                        (RequestType) call.argument("requestType"), (int) call.argument("status"),
                        (int) call.argument("duration"), (JSONObject) call.argument("request"),
                        (JSONObject) call.argument("response"));
                break;

            case "logEvent":
                Gleap.getInstance().logEvent((String) call.argument("logEvent"), (JSONObject) call.argument("data"));
                break;

            case "addAttachment":
                Gleap.getInstance().addAttachment((File) call.argument("file"));
                break;

            case "removeAllAttachments":
                Gleap.getInstance().removeAllAttachments();
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
