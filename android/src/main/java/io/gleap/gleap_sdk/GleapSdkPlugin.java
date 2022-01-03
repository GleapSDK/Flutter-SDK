package io.gleap.gleap_sdk;

import android.app.Application;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.Base64;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.gleap.APPLICATIONTYPE;
import io.gleap.CustomActionCallback;
import io.gleap.FeedbackSentCallback;
import io.gleap.FeedbackWillBeSentCallback;
import io.gleap.GetBitmapCallback;
import io.gleap.Gleap;
import io.gleap.GleapNotInitialisedException;
import io.gleap.GleapUserProperties;
import io.gleap.RequestType;

public class GleapSdkPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private static Application application;
    private FlutterPluginBinding flutterPluginBinding;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "gleap_sdk");
        channel.setMethodCallHandler(this);

        application = (Application) flutterPluginBinding.getApplicationContext();
        this.flutterPluginBinding = flutterPluginBinding;
    }

    private void initCustomAction() {
        Gleap.getInstance().setFeedbackWillBeSentCallback(new FeedbackWillBeSentCallback() {
            @Override
            public void flowInvoced() {
                channel.invokeMethod("feedbackWillBeSentCallback", null);
            }
        });

        Gleap.getInstance().setFeedbackSentCallback(new FeedbackSentCallback() {
            @Override
            public void close() {
                channel.invokeMethod("feedbackSentCallback", null);
            }
        });
    }

    private void initialize() {
        Gleap.getInstance().registerCustomAction(new CustomActionCallback() {
            @Override
            public void invoke(String message) {
                uiThreadHandler.post(() -> {
                    Map<String, String> map = new HashMap<>();
                    map.put("name", message);
                    channel.invokeMethod("customActionCallback", map);
                });
            }
        });

        Gleap.getInstance().setBitmapCallback(new GetBitmapCallback() {
            @Override
            public Bitmap getBitmap() {
                return flutterPluginBinding.getFlutterEngine().getRenderer().getBitmap();
            }
        });
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize":
                Gleap.getInstance().setApplicationType(APPLICATIONTYPE.FLUTTER);

                Gleap.initialize((String) call.argument("token"), application);

                initialize();
                initCustomAction();

                result.success(null);
                break;

            case "startFeedbackFlow":
                try {
                    Gleap.getInstance().startFeedbackFlow(call.argument("action"));
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

                Gleap.getInstance().sendSilentBugReport((String) call.argument("description"), severity);
                result.success(null);
                break;

            case "identify":

                if (call.argument("userProperties") != null) {
                    try {
                        JSONObject gleapUserProperty = new JSONObject((Map) call.argument("userProperties"));

                        GleapUserProperties gleapUserProperties = new GleapUserProperties(
                                gleapUserProperty.getString("name"), gleapUserProperty.getString("email"));
                        Gleap.getInstance().identifyUser(call.argument("userId"), gleapUserProperties);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                } else {
                    Gleap.getInstance().identifyUser(call.argument("userId"));
                }

                result.success(null);
                break;

            case "clearIdentity":
                Gleap.getInstance().clearIdentity();
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

            case "attachNetworkLogs":
                try {
                    JSONArray object = new JSONArray((Collection) call.argument("networkLogs"));
                    for (int i = 0; i < object.length(); i++) {
                        JSONObject currentRequest = (JSONObject) object.get(i);
                        JSONObject response = (JSONObject) currentRequest.get("response");
                        JSONObject request = new JSONObject();
                        if (currentRequest.has("request")) {
                            request = (JSONObject) currentRequest.get("request");
                        }
                        Gleap.getInstance().logNetwork(currentRequest.getString("url"),
                                RequestType.valueOf(currentRequest.getString("type")), response.getInt("status"),
                                currentRequest.getInt("duration"), request, response);
                    }

                } catch (Exception ex) {
                    System.out.println(ex);
                }

                result.success(null);
                break;

            case "logEvent":
                JSONObject data = new JSONObject((Map) call.argument("data"));

                Gleap.getInstance().logEvent((String) call.argument("logEvent"), data);
                result.success(null);
                break;

            case "addAttachment":
                try {
                    String fileName = call.argument("fileName");
                    String base64file = call.argument("base64file");
                    if (checkAllowedEndings(fileName)) {
                        String[] splittedBase64File = base64file.split(",");
                        byte[] fileData;
                        if (splittedBase64File.length == 2) {
                            fileData = Base64.getDecoder().decode(splittedBase64File[1]);
                        } else {
                            fileData = Base64.getDecoder().decode(splittedBase64File[0]);
                        }

                        String mimetype = extractMimeType(base64file);
                        String[] splitted = mimetype.split("/");
                        String fileNameConcated = fileName;
                        if (splitted.length == 2 && !fileName.contains(".")) {
                            fileNameConcated += "." + splitted[1];
                        }

                        File file = new File(application.getCacheDir() + "/" + fileNameConcated);
                        if (!file.exists()) {
                            file.createNewFile();
                        }
                        try (OutputStream stream = new FileOutputStream(file)) {
                            stream.write(fileData);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        if (file.exists()) {
                            Gleap.getInstance().addAttachment(file);
                        } else {
                            System.err.println("Gleap: The file is not existing.");
                        }
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                result.success(null);
                break;

            case "removeAllAttachments":
                Gleap.getInstance().removeAllAttachments();
                result.success(null);
                break;
            case "openWidget":
                try {
                    Gleap.getInstance().open();
                } catch (GleapNotInitialisedException e) {
                    e.printStackTrace();
                }
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

    /**
     * Extract the MIME type from a base64 string
     *
     * @param encoded Base64 string
     * @return MIME type string
     */
    private String extractMimeType(final String encoded) {
        final Pattern mime = Pattern.compile("^data:([a-zA-Z0-9]+/[a-zA-Z0-9]+).*,.*");
        final Matcher matcher = mime.matcher(encoded);
        if (!matcher.find())
            return "";
        return matcher.group(1).toLowerCase();
    }

    private boolean checkAllowedEndings(String fileName) {
        String[] fileType = fileName.split("\\.");
        String[] allowedTypes = { "jpeg", "svg", "png", "mp4", "webp", "xml", "plain", "xml", "json" };
        if (fileType.length <= 1) {
            return false;
        }
        boolean found = false;
        for (String type : allowedTypes) {
            if (type.equals(fileType[1])) {
                found = true;
            }
        }

        return found;
    }
}
