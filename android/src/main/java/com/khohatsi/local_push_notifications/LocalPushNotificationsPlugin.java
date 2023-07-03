package com.khohatsi.local_push_notifications;

import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.khohatsi.local_push_notifications.core.LocalNotifications;
import com.khohatsi.local_push_notifications.core.Definitions;
import com.khohatsi.local_push_notifications.core.completion_handlers.BitmapCompletionHandler;
import com.khohatsi.local_push_notifications.core.completion_handlers.NotificationThreadCompletionHandler;
import com.khohatsi.local_push_notifications.core.completion_handlers.PermissionCompletionHandler;
import com.khohatsi.local_push_notifications.core.enumerators.ForegroundServiceType;
import com.khohatsi.local_push_notifications.core.enumerators.ForegroundStartMode;
import com.khohatsi.local_push_notifications.core.exceptions.LocalNotificationsException;
import com.khohatsi.local_push_notifications.core.exceptions.ExceptionCode;
import com.khohatsi.local_push_notifications.core.exceptions.ExceptionFactory;
import com.khohatsi.local_push_notifications.core.listeners.LocalEventListener;
import com.khohatsi.local_push_notifications.core.logs.Logger;
import com.khohatsi.local_push_notifications.core.managers.PermissionManager;
import com.khohatsi.local_push_notifications.core.models.NotificationChannelModel;
import com.khohatsi.local_push_notifications.core.models.NotificationModel;
import com.khohatsi.local_push_notifications.core.models.NotificationScheduleModel;
import com.khohatsi.local_push_notifications.core.models.returnedData.ActionReceived;
import com.khohatsi.local_push_notifications.core.utils.CalendarUtils;
import com.khohatsi.local_push_notifications.core.utils.ListUtils;
import com.khohatsi.local_push_notifications.core.utils.MapUtils;
import com.khohatsi.local_push_notifications.core.utils.StringUtils;

/**
 * LocalNotificationsPlugin
 **/
public class LocalNotificationsPlugin
        implements
            FlutterPlugin,
            MethodCallHandler,
            PluginRegistry.NewIntentListener,
            ActivityAware
{
    private static final String TAG = "LocalNotificationsPlugin";

    private ActivityPluginBinding activityBinding;
    private final PluginRegistry.RequestPermissionsResultListener permissionsResultListener =
        new PluginRegistry.RequestPermissionsResultListener() {
            @Override
            public boolean onRequestPermissionsResult(
                    final int requestCode,
                    @NonNull final String[] permissions,
                    @NonNull final int[] grantResults
            ) {
                PermissionManager
                        .getInstance()
                        .handlePermissionResult(
                                requestCode,
                                permissions,
                                grantResults);
                return true;
            }
        };

    private final PluginRegistry.ActivityResultListener activityResultListener =
        new PluginRegistry.ActivityResultListener() {
            @Override
            public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
                PermissionManager
                        .getInstance()
                        .handleActivityResult(
                                requestCode,
                                resultCode,
                                data);
                return true;
            }
        };

    private MethodChannel pluginChannel;
    private final LocalEventListener localEventListener = new LocalEventListener() {
        @Override
        public void onNewLocalEvent(String eventType, Map<String, Object> content) {
            if (pluginChannel != null){
                if(Definitions.EVENT_SILENT_ACTION.equals(eventType)){
                    try {
                        Long actionHandle = (localNotifications != null) ? localNotifications.getActionHandle() : null;
                        content.put(Definitions.ACTION_HANDLE, actionHandle);
                    } catch (LocalNotificationsException ignore) {
                    }
                }
                pluginChannel.invokeMethod(eventType, content);
            }
        }
    };
    private LocalNotifications localNotifications;

    private final StringUtils stringUtils = StringUtils.getInstance();

    // https://flutter.dev/docs/development/packages-and-plugins/plugin-api-migration
    // FOR OLDER FLUTTER VERSIONS (1.11 releases and bellow)
    public static void registerWith(Registrar registrar) {

        LocalNotificationsPlugin localNotificationsPlugin
                = new LocalNotificationsPlugin();

        localNotificationsPlugin.AttachLocalNotificationsPlugin(
                registrar.context(),
                new MethodChannel(
                        registrar.messenger(),
                        Definitions.CHANNEL_FLUTTER_PLUGIN
                ));
    }

    // FOR NEWER FLUTTER VERSIONS (1.12 releases and above)
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

        AttachLocalNotificationsPlugin(
                flutterPluginBinding.getApplicationContext(),
                new MethodChannel(
                    flutterPluginBinding.getBinaryMessenger(),
                    Definitions.CHANNEL_FLUTTER_PLUGIN
                ));

        if (LocalNotifications.debug)
            Logger.d(TAG, "Local Notifications attached to engine for Android " + Build.VERSION.SDK_INT);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        detachLocalNotificationsPlugin(
                binding.getApplicationContext());
    }

    private void AttachLocalNotificationsPlugin(Context applicationContext, MethodChannel channel) {
        pluginChannel = channel;
        pluginChannel.setMethodCallHandler(this);

        try {
            LocalNotificationsFlutterExtension.initialize();
            localNotifications = new LocalNotifications(applicationContext);

            if (LocalNotifications.debug)
                Logger.d(TAG, "Local Notifications plugin attached to Android " + Build.VERSION.SDK_INT);

        } catch (LocalNotificationsException ignored) {
        } catch (Exception exception) {
            ExceptionFactory
                .getInstance()
                .registerNewLocalException(
                        TAG,
                        ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                        "An exception was found while attaching local notifications plugin",
                        exception);
        }
    }

    private void detachLocalNotificationsPlugin(Context applicationContext) {
        pluginChannel.setMethodCallHandler(null);
        pluginChannel = null;

        if (localNotifications != null) {
            localNotifications.detachAsMainInstance(localEventListener);
            localNotifications.dispose();
            localNotifications = null;
        }

        if (LocalNotifications.debug)
            Logger.d(TAG, "Local Notifications plugin detached from Android " + Build.VERSION.SDK_INT);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        try {
            activityBinding = binding;

            activityBinding.addRequestPermissionsResultListener(permissionsResultListener);
            activityBinding.addActivityResultListener(activityResultListener);

            if(localNotifications != null){
                localNotifications.captureNotificationActionFromActivity(binding.getActivity());
            }

            activityBinding.addOnNewIntentListener(this);

        } catch(Exception exception) {
            ExceptionFactory
                    .getInstance()
                    .registerNewLocalException(
                            TAG,
                            ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                            ExceptionCode.DETAILED_UNEXPECTED_ERROR+".fcm."+exception.getClass().getSimpleName(),
                            exception);
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activityBinding.removeRequestPermissionsResultListener(permissionsResultListener);
        activityBinding.removeActivityResultListener(activityResultListener);
        activityBinding.removeOnNewIntentListener(this);
        activityBinding = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        activityBinding.addRequestPermissionsResultListener(permissionsResultListener);
        activityBinding.addActivityResultListener(activityResultListener);
        activityBinding.addOnNewIntentListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        activityBinding.removeRequestPermissionsResultListener(permissionsResultListener);
        activityBinding.removeActivityResultListener(activityResultListener);
        activityBinding.removeOnNewIntentListener(this);
        activityBinding = null;
    }

    @Override
    public boolean onNewIntent(@NonNull Intent intent) {
        try{
            return localNotifications
                    .captureNotificationActionFromIntent(intent);
        } catch (Exception exception) {
            ExceptionFactory
                    .getInstance()
                    .registerNewLocalException(
                            TAG,
                            ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                            ExceptionCode.DETAILED_UNEXPECTED_ERROR+".fcm."+exception.getClass().getSimpleName(),
                            exception);
            return false;
        }
    }

    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {

        if (localNotifications == null) {
            LocalNotificationsException localException =
                    ExceptionFactory
                        .getInstance()
                        .createNewLocalException(
                                TAG,
                                ExceptionCode.CODE_INITIALIZATION_EXCEPTION,
                                "Local notifications is currently not available",
                                ExceptionCode.DETAILED_INITIALIZATION_FAILED+".localNotifications.core");
            result.error(
                    localException.getCode(),
                    localException.getMessage(),
                    localException.getDetailedCode());
            return;
        }

        try {

            switch (call.method) {

                case Definitions.CHANNEL_METHOD_INITIALIZE:
                    channelMethodInitialize(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SET_ACTION_HANDLE:
                    channelMethodSetActionHandle(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_DRAWABLE_DATA:
                    channelMethodGetDrawableData(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_IS_NOTIFICATION_ALLOWED:
                    channelIsNotificationAllowed(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SHOW_NOTIFICATION_PAGE:
                    channelShowNotificationPage(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SHOW_ALARM_PAGE:
                    channelShowAlarmPage(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SHOW_GLOBAL_DND_PAGE:
                    channelShowGlobalDndPage(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CHECK_PERMISSIONS:
                    channelMethodCheckPermissions(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SHOULD_SHOW_RATIONALE:
                    channelMethodShouldShowRationale(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_REQUEST_NOTIFICATIONS:
                    channelRequestUserPermissions(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CREATE_NOTIFICATION:
                    channelMethodCreateNotification(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_LIST_ALL_SCHEDULES:
                    channelMethodListAllSchedules(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_INITIAL_ACTION:
                    channelMethodGetInitialAction(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CLEAR_STORED_ACTION:
                    channelMethodClearStoredActions(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_NEXT_DATE:
                    channelMethodGetNextDate(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_LOCAL_TIMEZONE_IDENTIFIER:
                    channelMethodGetLocalTimeZone(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_UTC_TIMEZONE_IDENTIFIER:
                    channelMethodGetUtcTimeZone(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_APP_LIFE_CYCLE:
                    channelMethodGetLifeCycle(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SET_NOTIFICATION_CHANNEL:
                    channelMethodSetChannel(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_REMOVE_NOTIFICATION_CHANNEL:
                    channelMethodRemoveChannel(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_GET_BADGE_COUNT:
                    channelMethodGetBadgeCounter(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_SET_BADGE_COUNT:
                    channelMethodSetBadgeCounter(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_INCREMENT_BADGE_COUNT:
                    channelMethodIncrementBadge(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_DECREMENT_BADGE_COUNT:
                    channelMethodDecrementBadge(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_RESET_BADGE:
                    channelMethodResetBadge(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATION:
                    channelMethodDismissNotification(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATION:
                    channelMethodCancelNotification(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULE:
                    channelMethodCancelSchedule(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATIONS_BY_CHANNEL_KEY:
                    channelMethodDismissNotificationsByChannelKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULES_BY_CHANNEL_KEY:
                    channelMethodCancelSchedulesByChannelKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATIONS_BY_CHANNEL_KEY:
                    channelMethodCancelNotificationsByChannelKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_DISMISS_NOTIFICATIONS_BY_GROUP_KEY:
                    channelMethodDismissNotificationsByGroupKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_SCHEDULES_BY_GROUP_KEY:
                    channelMethodCancelSchedulesByGroupKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_NOTIFICATIONS_BY_GROUP_KEY:
                    channelMethodCancelNotificationsByGroupKey(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_DISMISS_ALL_NOTIFICATIONS:
                    channelMethodDismissAllNotifications(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_ALL_SCHEDULES:
                    channelMethodCancelAllSchedules(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_CANCEL_ALL_NOTIFICATIONS:
                    channelMethodCancelAllNotifications(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_START_FOREGROUND:
                    channelMethodStartForeground(call, result);
                    return;

                case Definitions.CHANNEL_METHOD_STOP_FOREGROUND:
                    channelMethodStopForeground(call, result);
                    return;

                default:
                    result.notImplemented();
            }

        } catch (LocalNotificationsException localException) {
            result.error(
                    localException.getCode(),
                    localException.getMessage(),
                    localException.getDetailedCode());

        } catch (Exception exception) {
            LocalNotificationsException localException =
                    ExceptionFactory
                        .getInstance()
                        .createNewLocalException(
                                TAG,
                                ExceptionCode.CODE_UNKNOWN_EXCEPTION,
                                ExceptionCode.DETAILED_UNEXPECTED_ERROR+"."+exception.getClass().getSimpleName(),
                                exception);

            result.error(
                    localException.getCode(),
                    localException.getMessage(),
                    localException.getDetailedCode());
        }
    }

    @SuppressWarnings("unchecked")
    private void channelMethodStartForeground(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Map<String, Object> arguments = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        NotificationModel notificationModel = new NotificationModel().fromMap(
                (Map<String, Object>) arguments.get(Definitions.NOTIFICATION_MODEL));

        if(notificationModel == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Foreground notification is invalid",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".notificationModel");

        ForegroundStartMode foregroundStartMode =
                notificationModel.getValueOrDefault(arguments, Definitions.NOTIFICATION_SERVICE_START_MODE,
                        ForegroundStartMode.class, ForegroundStartMode.stick);

        ForegroundServiceType foregroundServiceType =
                notificationModel.getValueOrDefault(arguments, Definitions.NOTIFICATION_FOREGROUND_SERVICE_TYPE,
                        ForegroundServiceType.class, ForegroundServiceType.none);

        if(foregroundStartMode == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Foreground start type is required",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".foreground.startType");

        if(foregroundServiceType == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "foregroundServiceType is required",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".foreground.serviceType");

        localNotifications.startForegroundService(
            notificationModel,
            foregroundStartMode,
            foregroundServiceType);
    }

    private void channelMethodStopForeground(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Integer notificationId = call.<Integer>argument(Definitions.NOTIFICATION_ID);
        localNotifications.stopForegroundService(notificationId);
        result.success(null);
    }

    private void channelMethodGetDrawableData(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String bitmapReference = call.arguments();
        if(bitmapReference == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Bitmap reference is required",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".bitmapReference");

        localNotifications
                .getDrawableData(
                    bitmapReference,
                    new BitmapCompletionHandler() {
                        @Override
                        public void handle(byte[] byteArray, LocalNotificationsException exception) {
                            if(exception != null)
                                result.error(
                                        exception.getCode(),
                                        exception.getMessage(),
                                        exception.getDetailedCode());
                            else
                                result.success(byteArray);
                        }
                    });
    }

    @SuppressWarnings("unchecked")
    private void channelMethodSetChannel(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Map<String, Object> channelData = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if (channelData == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Channel data is missing",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.data");

        NotificationChannelModel channelModel = new NotificationChannelModel().fromMap(channelData);
        if (channelModel == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Channel data is invalid",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.data");

        Object forceUpdateObject = channelData.get(Definitions.CHANNEL_FORCE_UPDATE);
        boolean forceUpdate =
                forceUpdateObject != null && Boolean.parseBoolean(forceUpdateObject.toString());

        boolean channelSaved =
                localNotifications
                        .setChannel(channelModel, forceUpdate);

        result.success(channelSaved);
    }

    private void channelMethodRemoveChannel(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String channelKey = call.arguments();
        if (stringUtils.isNullOrEmpty(channelKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Empty channel key",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".channel.key");

        boolean removed =
                localNotifications
                        .removeChannel(channelKey);

        if (LocalNotifications.debug)
            Logger.d(TAG, removed ?
                    "Channel removed" :
                    "Channel '" + channelKey + "' not found");

        result.success(removed);
    }

    private void channelMethodGetBadgeCounter(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        Integer badgeCount =
                localNotifications
                        .getGlobalBadgeCounter();

        result.success(badgeCount);
    }

    private void channelMethodSetBadgeCounter(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        int count = MapUtils.extractArgument(call.arguments(), Integer.class).or(-1);
        if (count < 0)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid Badge value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".badge.value");

        localNotifications.setGlobalBadgeCounter(count);
        result.success(true);
    }

    private void channelMethodResetBadge(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        localNotifications.resetGlobalBadgeCounter();
        result.success(null);
    }

    private void channelMethodIncrementBadge(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        int badgeCount = localNotifications.incrementGlobalBadgeCounter();
        result.success(badgeCount);
    }

    private void channelMethodDecrementBadge(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        int badgeCount = localNotifications.decrementGlobalBadgeCounter();
        result.success(badgeCount);
    }

    private void channelMethodDismissNotification(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Integer notificationId = call.arguments();
        if (notificationId == null || notificationId < 0)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid id value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id");

        boolean dismissed = localNotifications.dismissNotification(notificationId);

        if (LocalNotifications.debug)
            Logger.d(TAG, dismissed ?
                    "Notification " + notificationId + " dismissed" :
                    "Notification " + notificationId + " was not found");

        result.success(dismissed);
    }

    private void channelMethodCancelSchedule(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Integer notificationId = call.arguments();
        if (notificationId == null || notificationId < 0)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid id value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id");

        boolean canceled = localNotifications.cancelSchedule(notificationId);

        if (LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Schedule " + notificationId + " cancelled" :
                    "Schedule " + notificationId + " was not found");

        result.success(canceled);
    }

    private void channelMethodCancelNotification(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Integer notificationId = call.arguments();
        if (notificationId == null || notificationId < 0)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid id value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.id");

        boolean canceled = localNotifications.cancelNotification(notificationId);

        if (LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Notification " + notificationId + " cancelled" :
                    "Notification " + notificationId + " was not found");

        result.success(canceled);
    }

    private void channelMethodDismissNotificationsByChannelKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String channelKey = call.arguments();
        if (stringUtils.isNullOrEmpty(channelKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid channel Key value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey");

        boolean dismissed = localNotifications.dismissNotificationsByChannelKey(channelKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, dismissed ?
                    "Notifications from channel " + channelKey + " dismissed" :
                    "Notifications from channel " + channelKey + " not found");

        result.success(dismissed);
    }

    private void channelMethodCancelSchedulesByChannelKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String channelKey = call.arguments();
        if (stringUtils.isNullOrEmpty(channelKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid channel Key value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey");

        boolean canceled = localNotifications.cancelSchedulesByChannelKey(channelKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Scheduled Notifications from channel " + channelKey + " canceled" :
                    "Scheduled Notifications from channel " + channelKey + " not found");

        result.success(canceled);
    }

    private void channelMethodCancelNotificationsByChannelKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String channelKey = call.arguments();
        if (stringUtils.isNullOrEmpty(channelKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid channel Key value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.channelKey");

        boolean canceled = localNotifications.cancelNotificationsByChannelKey(channelKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Notifications and schedules from channel " + channelKey + " canceled" :
                    "Notifications and schedules from channel " + channelKey + " not found");

        result.success(canceled);
    }

    private void channelMethodDismissNotificationsByGroupKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String groupKey = call.arguments();
        if (stringUtils.isNullOrEmpty(groupKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid groupKey value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey");

        boolean dismissed = localNotifications.dismissNotificationsByGroupKey(groupKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, dismissed ?
                    "Notifications from group " + groupKey + " dismissed" :
                    "Notifications from group " + groupKey + " not found");

        result.success(dismissed);
    }

    private void channelMethodCancelSchedulesByGroupKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String groupKey = call.arguments();
        if (stringUtils.isNullOrEmpty(groupKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid groupKey value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey");

        boolean canceled = localNotifications.cancelSchedulesByGroupKey(groupKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Scheduled Notifications from group " + groupKey + " canceled" :
                    "Scheduled Notifications from group " + groupKey + " not found");

        result.success(canceled);
    }

    private void channelMethodCancelNotificationsByGroupKey(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        String groupKey = call.arguments();
        if (stringUtils.isNullOrEmpty(groupKey))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Invalid groupKey value",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".dismiss.groupKey");

        boolean canceled = localNotifications.cancelNotificationsByGroupKey(groupKey);

        if(LocalNotifications.debug)
            Logger.d(TAG, canceled ?
                    "Notifications and schedules from group " + groupKey + " canceled" :
                    "Notifications and schedules from group " + groupKey + " not found to be");

        result.success(canceled);
    }

    private void channelMethodDismissAllNotifications(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        localNotifications.dismissAllNotifications();

        if (LocalNotifications.debug)
            Logger.d(TAG, "All notifications was dismissed");

        result.success(true);
    }

    private void channelMethodCancelAllSchedules(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        localNotifications.cancelAllSchedules();

        if (LocalNotifications.debug)
            Logger.d(TAG, "All notifications scheduled was cancelled");

        result.success(true);
    }

    private void channelMethodCancelAllNotifications(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        localNotifications.cancelAllNotifications();

        if (LocalNotifications.debug)
            Logger.d(TAG, "All notifications was cancelled");

        result.success(true);
    }

    private void channelMethodListAllSchedules(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        List<NotificationModel> activeSchedules =
                localNotifications.listAllPendingSchedules();

        List<Map<String, Object>> listSerialized = new ArrayList<>();

        if (activeSchedules != null)
            for (NotificationModel notificationModel : activeSchedules) {
                Map<String, Object> serialized = notificationModel.toMap();
                listSerialized.add(serialized);
            }

        result.success(listSerialized);
    }

    private void channelMethodGetInitialAction(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        boolean removeFromEvents = !Boolean.FALSE.equals(call.arguments());
        ActionReceived actionReceived = localNotifications
                .getInitialNotificationAction(removeFromEvents);

        if (actionReceived == null)
            result.success(null);
        else
            result.success(actionReceived.toMap());
    }

    private void channelMethodClearStoredActions(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        localNotifications.clearStoredActions();
        result.success(null);
    }

    @SuppressWarnings("unchecked")
    private void channelMethodGetNextDate(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Map<String, Object> data = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if (data == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Schedule data is invalid",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".schedule.data");

        Map<String, Object> scheduleData =
                MapUtils.extractValue(data, Definitions.NOTIFICATION_MODEL_SCHEDULE, Map.class)
                    .orNull();

        if (scheduleData == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Schedule data is invalid",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".schedule.data");

        NotificationScheduleModel scheduleModel =
                NotificationScheduleModel
                        .getScheduleModelFromMap(scheduleData);

        if (scheduleModel == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Schedule data is invalid",
                            ExceptionCode.DETAILED_INVALID_ARGUMENTS+".schedule.data");

        Calendar fixedDate =
                MapUtils.extractValue(data, Definitions.NOTIFICATION_INITIAL_FIXED_DATE, Calendar.class)
                            .or(CalendarUtils.getInstance().getCurrentCalendar());

        Calendar nextValidDate =
                localNotifications
                        .getNextValidDate(scheduleModel, fixedDate);

        String finalValidDateString =
                (nextValidDate == null) ? null :
                CalendarUtils
                    .getInstance()
                    .calendarToString(nextValidDate);

        result.success(finalValidDateString);
    }

    private void channelMethodGetLocalTimeZone(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        result.success(
                localNotifications
                        .getLocalTimeZone());
    }

    private void channelMethodGetUtcTimeZone(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        result.success(
                localNotifications
                        .getUtcTimeZone());
    }

    private void channelMethodGetLifeCycle(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        result.success(
                localNotifications
                    .getApplicationLifeCycle()
                    .getSafeName());
    }

    private void channelIsNotificationAllowed(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        result.success(
                localNotifications
                        .areNotificationsGloballyAllowed());
    }

    private void channelShowNotificationPage(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        String channelKey = call.arguments();

        localNotifications
                .showNotificationPage(
                    channelKey,
                    new PermissionCompletionHandler() {
                        @Override
                        public void handle(List<String> missingPermissions) {
                            result.success(missingPermissions);
                        }
                    }
                );
    }

    private void channelShowAlarmPage(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        localNotifications
                .showPreciseAlarmPage(
                    new PermissionCompletionHandler() {
                        @Override
                        public void handle(List<String> missingPermissions) {
                            result.success(missingPermissions);
                        }
                    }
                );
    }

    private void channelShowGlobalDndPage(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {
        localNotifications
                .showDnDGlobalOverridingPage(
                        new PermissionCompletionHandler() {
                            @Override
                            public void handle(List<String> missingPermissions) {
                                result.success(missingPermissions);
                            }
                        }
                );
    }

    @SuppressWarnings("unchecked")
    private void channelMethodCheckPermissions(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws LocalNotificationsException {

        Map<String, Object> arguments = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        String channelKey = (String) arguments.get(Definitions.NOTIFICATION_CHANNEL_KEY);

        List<String> permissions = (List<String>) arguments.get(Definitions.NOTIFICATION_PERMISSIONS);
        if(ListUtils.isNullOrEmpty(permissions))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Permission list is required",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList");

        permissions = localNotifications
                        .arePermissionsAllowed(
                                channelKey,
                                permissions);

        result.success(permissions);
    }

    @SuppressWarnings("unchecked")
    private void channelMethodShouldShowRationale(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws Exception {

        Map<String, Object> arguments = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        String channelKey = (String) arguments.get(Definitions.NOTIFICATION_CHANNEL_KEY);
        List<String> permissions = (List<String>) arguments.get(Definitions.NOTIFICATION_PERMISSIONS);

        if(permissions == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Permission list is required",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList");

        if(permissions.isEmpty())
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Permission list cannot be empty",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList");

        permissions = localNotifications.shouldShowRationale(
                        channelKey,
                        permissions);

        result.success(permissions);
    }

    @SuppressWarnings("unchecked")
    private void channelRequestUserPermissions(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws Exception {

        Map<String, Object> arguments = MapUtils.extractArgument(call.arguments(), Map.class).orNull();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        if(!arguments.containsKey(Definitions.NOTIFICATION_PERMISSIONS))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Permission list is required",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList");

        String channelKey = (String) arguments.get(Definitions.NOTIFICATION_CHANNEL_KEY);
        List<String> permissions = (List<String>) arguments.get(Definitions.NOTIFICATION_PERMISSIONS);

        if(ListUtils.isNullOrEmpty(permissions))
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Permission list is required",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".permissionList");

        localNotifications
                .requestUserPermissions(
                    activityBinding.getActivity(),
                    channelKey,
                    permissions,
                    new PermissionCompletionHandler() {
                        @Override
                        public void handle(List<String> missingPermissions) {
                            result.success(missingPermissions);
                        }
                    });
    }

    private void channelMethodCreateNotification(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws Exception {

        Map<String, Object> arguments = call.arguments();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        NotificationModel notificationModel = new NotificationModel().fromMap(arguments);

        if (notificationModel == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_INVALID_ARGUMENTS,
                            "Notification content is invalid",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS+".notificationModel.data");

        localNotifications.createNotification(
                notificationModel,
                new NotificationThreadCompletionHandler() {
                    @Override
                    public void handle(boolean success, LocalNotificationsException exception) {
                        if (exception != null)
                            result.error(
                                    exception.getCode(),
                                    exception.getLocalizedMessage(),
                                    exception.getDetailedCode());
                        else
                            result.success(success);
                    }
                });
    }

    @SuppressWarnings("unchecked")
    private void channelMethodInitialize(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws Exception {

        Map<String, Object> arguments = call.arguments();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        String defaultIconPath = (String) arguments.get(Definitions.INITIALIZE_DEFAULT_ICON);

        List<Object> channelsData = (List<Object>) arguments.get(Definitions.INITIALIZE_CHANNELS);
        List<Object> channelGroupsData = (List<Object>) arguments.get(Definitions.INITIALIZE_CHANNEL_GROUPS);

        Boolean debug = (Boolean) arguments.get(Definitions.INITIALIZE_DEBUG_MODE);
        debug = debug != null && debug;

        Object backgroundCallbackObj = arguments.get(Definitions.BACKGROUND_HANDLE);
        Long backgroundCallback = backgroundCallbackObj == null ? 0L :((Number) backgroundCallbackObj).longValue();

        localNotifications.initialize(
                defaultIconPath,
                channelsData,
                channelGroupsData,
                backgroundCallback,
                debug);

        if (LocalNotifications.debug)
            Logger.d(TAG, "Local Notifications Flutter plugin initialized");

        result.success(true);
    }

    @SuppressWarnings("unchecked")
    private void channelMethodSetActionHandle(
            @NonNull final MethodCall call,
            @NonNull final Result result
    ) throws Exception {

        Map<String, Object> arguments = call.arguments();
        if(arguments == null)
            throw ExceptionFactory
                    .getInstance()
                    .createNewLocalException(
                            TAG,
                            ExceptionCode.CODE_MISSING_ARGUMENTS,
                            "Arguments are missing",
                            ExceptionCode.DETAILED_REQUIRED_ARGUMENTS);

        Object callbackActionObj = arguments.get(Definitions.ACTION_HANDLE);

        long silentCallback = callbackActionObj == null ? 0L : ((Number) callbackActionObj).longValue();

        localNotifications.attachAsMainInstance(localEventListener);
        localNotifications.setActionHandle(silentCallback);

        boolean success = silentCallback != 0L;
        if(!success)
            Logger.w(
                    TAG,
                    "Attention: there is no valid static" +
                            " method to receive notification actions in background");

        result.success(success);
    }
}

