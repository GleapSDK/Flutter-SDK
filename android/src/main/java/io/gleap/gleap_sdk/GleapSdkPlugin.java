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
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.gleap.APPLICATIONTYPE;
import io.gleap.Gleap;
import io.gleap.GleapActivationMethod;
import io.gleap.GleapLogLevel;
import io.gleap.GleapUser;
import io.gleap.Networklog;
import io.gleap.GleapUserProperties;
import io.gleap.PrefillHelper;
import io.gleap.RequestType;
import io.gleap.callbacks.CustomActionCallback;
import io.gleap.callbacks.FeedbackFlowStartedCallback;
import io.gleap.callbacks.FeedbackSendingFailedCallback;
import io.gleap.callbacks.FeedbackSentCallback;
import io.gleap.callbacks.GetBitmapCallback;
import io.gleap.callbacks.WidgetClosedCallback;
import io.gleap.callbacks.WidgetOpenedCallback;

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
        Gleap.getInstance().setFeedbackFlowStartedCallback(new FeedbackFlowStartedCallback() {
            @Override
            public void invoke(String message) {
                channel.invokeMethod("feedbackFlowStarted", message);
            }
        });

        Gleap.getInstance().setWidgetOpenedCallback(new WidgetOpenedCallback() {
            @Override
            public void invoke() {
                channel.invokeMethod("widgetOpened", null);
            }
        });

        Gleap.getInstance().setWidgetClosedCallback(new WidgetClosedCallback() {
            @Override
            public void invoke() {
                channel.invokeMethod("widgetClosed", null);
            }
        });

        Gleap.getInstance().setFeedbackSentCallback(new FeedbackSentCallback() {
            @Override
            public void invoke(String message) {
                channel.invokeMethod("feedbackSent", null);
            }
        });

        Gleap.getInstance().setFeedbackSendingFailedCallback(new FeedbackSendingFailedCallback() {
            @Override
            public void invoke(String message) {
                channel.invokeMethod("feedbackSendingFailed", null);
            }
        });


        Gleap.getInstance().registerCustomAction(new CustomActionCallback() {
            @Override
            public void invoke(String message) {
                uiThreadHandler.post(() -> {
                    Map<String, String> map = new HashMap<>();
                    map.put("name", message);
                    channel.invokeMethod("customActionTriggered", map);
                });
            }
        });
    }

    private void initialize() {
        Gleap.getInstance().setBitmapCallback(new GetBitmapCallback() {
            @Override
            public Bitmap getBitmap() {
                return flutterPluginBinding.getFlutterEngine().getRenderer().getBitmap();
            }
        });
    }

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
                Gleap.getInstance().startFeedbackFlow(call.argument("action"), ((Boolean) call.argument("showBackButton")));
                result.success(null);
                break;

            case "sendSilentCrashReport":
                Gleap.SEVERITY severity = Gleap.SEVERITY.MEDIUM;
                if (call.argument("severity").equals("LOW")) {
                    severity = Gleap.SEVERITY.LOW;
                } else if (call.argument("severity").equals("MEDIUM")) {
                    severity = Gleap.SEVERITY.MEDIUM;
                } else if (call.argument("severity").equals("HIGH")) {
                    severity = Gleap.SEVERITY.HIGH;
                }

                try {
                    if(call.argument("excludeData") != null) {
                        JSONObject excludeData = new JSONObject((Map) call.argument("excludeData"));
                        Gleap.getInstance().sendSilentCrashReport((String) call.argument("description"), severity, excludeData);
                    } else {
                        Gleap.getInstance().sendSilentCrashReport((String) call.argument("description"), severity);
                    }
                }catch (Exception ex) {}

                result.success(null);
                break;

            case "identify":
                if (call.argument("userProperties") != null) {
                    try {
                        JSONObject gleapUserProperty = new JSONObject((Map) call.argument("userProperties"));
                        GleapUserProperties gleapUserProperties = new GleapUserProperties();

                        if(gleapUserProperty.has("email") && !gleapUserProperty.isNull("email")) {
                            gleapUserProperties.setEmail(gleapUserProperty.getString("email"));
                        }
                        if(gleapUserProperty.has("name") && !gleapUserProperty.isNull("name")) {
                            gleapUserProperties.setName(gleapUserProperty.getString("name"));
                        }
                        if(gleapUserProperty.has("phone") && !gleapUserProperty.isNull("phone")) {
                            gleapUserProperties.setPhoneNumber(gleapUserProperty.getString("phone"));
                        }
                        if(gleapUserProperty.has("value") && !gleapUserProperty.isNull("value")) {
                            gleapUserProperties.setValue(gleapUserProperty.getDouble("value"));
                        }
                        if(gleapUserProperty.has("customData") && !gleapUserProperty.isNull("customData")) {
                            gleapUserProperties.setCustomData(gleapUserProperty.getJSONObject("customData"));
                        }

                        if(call.argument("userHash") != null) {
                            gleapUserProperties.setHash(call.argument("userHash"));
                        }
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

            case "setActivationMethods":
                try {
                    ArrayList<String> activationMethods = call.argument("activationMethods");
                    ArrayList<GleapActivationMethod> internalActivationMethods = new ArrayList<>();
                    for (int i = 0; i < activationMethods.size(); i++) {
                        if (activationMethods.get(i).equalsIgnoreCase("SHAKE")) {
                            internalActivationMethods.add(GleapActivationMethod.SHAKE);
                        }
                        if (activationMethods.get(i).equalsIgnoreCase("SCREENSHOT")) {
                            internalActivationMethods.add(GleapActivationMethod.SCREENSHOT);
                        }
                    }
                    Gleap.getInstance().setActivationMethods(internalActivationMethods.toArray(new GleapActivationMethod[internalActivationMethods.size()]));
                } catch (Exception ex) {
                    System.out.println(ex);
                }

                result.success(null);
                break;

            case "attachNetworkLogs":
                try {
                    JSONArray object = new JSONArray((Collection) call.argument("networkLogs"));
                    Networklog[] networklogs = new Networklog[object.length()];
                    for (int i = 0; i < object.length(); i++) {
                        JSONObject currentRequest = (JSONObject) object.get(i);
                        JSONObject response = (JSONObject) currentRequest.get("response");
                        JSONObject request = new JSONObject();
                        if (currentRequest.has("request")) {
                            request = (JSONObject) currentRequest.get("request");
                        }
                        networklogs[i] = new Networklog(currentRequest.getString("url"),
                                RequestType.valueOf(currentRequest.getString("type")), response.getInt("status"),
                                currentRequest.getInt("duration"), request, response);
                    }

                    Gleap.getInstance().attachNetworkLogs(networklogs);
                } catch (Exception ex) {
                    System.out.println(ex);
                }

                result.success(null);
                break;

            case "trackEvent":
                JSONObject data = new JSONObject((Map) call.argument("data"));

                Gleap.getInstance().trackEvent((String) call.argument("name"), data);
                result.success(null);
                break;

            case "trackPage":
                try {
                    JSONObject body = new JSONObject();
                    body.put("page", (String) call.argument("pageName"));
                    Gleap.getInstance().trackEvent("pageView", body);
                } catch (Exception ignore) {
                }
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
                    } else {
                        throw new NotSupportedFileTypeException();
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
                Gleap.getInstance().open();
                result.success(null);
                break;
            case "closeWidget":
                Gleap.getInstance().close();
                result.success(null);
                break;
            case "setApiUrl":
                Gleap.getInstance().setApiUrl((String) call.argument("url"));
                result.success(null);
                break;
            case "setFrameUrl":
                Gleap.getInstance().setFrameUrl((String) call.argument("url"));
                result.success(null);
                break;
            case "preFillForm":
                try{
                    if(call.argument("formData")!= null) {
                        JSONObject prefill = new JSONObject((Map) call.argument("formData"));
                        PrefillHelper.getInstancen().setPrefillData(prefill);
                    }
                }catch (Exception ex) {}
                break;

            case "isOpened":
                result.success(Gleap.getInstance().isOpened());
                break;
            case "log":
                if(call.argument("logLevel") != null) {
                    GleapLogLevel logLevel = GleapLogLevel.INFO;
                    if (call.argument("logLevel").equals("INFO")) {
                        logLevel = GleapLogLevel.INFO;
                    } else if (call.argument("logLevel").equals("WARNING")) {
                        logLevel = GleapLogLevel.WARNING;
                    } else if (call.argument("logLevel").equals("ERROR")) {
                        logLevel = GleapLogLevel.ERROR;
                    }

                    Gleap.getInstance().log((String) call.argument("message"), logLevel);
                } else {
                    Gleap.getInstance().log((String) call.argument("message"));
                }

                result.success(true);
                break;
            case "disableConsoleLog":
                Gleap.getInstance().disableConsoleLog();

                result.success(true);
                break;

            case "showFeedbackButton":
                Gleap.getInstance().showFeedbackButton(((Boolean) call.argument("visible")));

                result.success(true);
                break;

            case "openNews":
                Gleap.getInstance().openNews(((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "openNewsArticle":
                Gleap.getInstance().openNewsArticle((String) call.argument("articleId"), ((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "openFeatureRequests":
                Gleap.getInstance().openFeatureRequests(((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "openHelpCenter":
                Gleap.getInstance().openHelpCenter(((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "openHelpCenterArticle":
                Gleap.getInstance().openHelpCenterArticle((String) call.argument("articleId"), ((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "openHelpCenterCollection":
                Gleap.getInstance().openHelpCenterArticle((String) call.argument("collectionId"), ((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "searchHelpCenter":
                Gleap.getInstance().searchHelpCenter((String) call.argument("term"), ((Boolean) call.argument("showBackButton")));

                result.success(true);
                break;

            case "isUserIdentified":
               boolean isUserIdentified = Gleap.getInstance().isUserIdentified();
               result.success(isUserIdentified);
               break;

            case "getIdentity":
                try {
                    GleapUser gleapUser = Gleap.getInstance().getIdentity();
                    if (gleapUser != null) {
                        GleapUserProperties userProps = gleapUser.getGleapUserProperties();

                        Map<String, Object> map = new HashMap<>();

                        if (userProps != null) {
                            map.put("userId", gleapUser.getUserId());
                            map.put("phone", userProps.getPhoneNumber());
                            map.put("email", userProps.getEmail());
                            map.put("name", userProps.getName());
                            map.put("value", userProps.getValue());
                        }

                        result.success(map);
                    } else {
                        result.success(null);
                    }
                }catch (Exception ex) {
                    result.success(null);
                }
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
        String[] allowedTypes = {"jpeg", "svg", "png", "mp4", "webp", "xml", "plain", "xml", "json"};
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
