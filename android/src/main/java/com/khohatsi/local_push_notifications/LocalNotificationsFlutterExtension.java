package com.khohatsi.local_push_notifications;

import android.content.Context;

import com.khohatsi.local_push_notifications.core.LocalNotifications;
import com.khohatsi.local_push_notifications.core.LocalNotificationsExtension;
import com.khohatsi.local_push_notifications.core.background.BackgroundExecutor;
import com.khohatsi.local_push_notifications.core.logs.Logger;

public class LocalNotificationsFlutterExtension extends LocalNotificationsExtension {
    private static final String TAG = "LocalNotificationsFlutterExtension";

    public static void initialize(){
        if(LocalNotifications.localExtensions != null) return;

        LocalNotifications.actionReceiverClass = DartNotificationActionReceiver.class;
        LocalNotifications.dismissReceiverClass = DartDismissedNotificationReceiver.class;
        LocalNotifications.scheduleReceiverClass = DartScheduledNotificationReceiver.class;
        LocalNotifications.backgroundServiceClass = DartBackgroundService.class;

        LocalNotifications.localExtensions = new LocalNotificationsFlutterExtension();

        if (LocalNotifications.debug)
            Logger.d(TAG, "Flutter extensions attached to Local Notification's core.");
    }

    @Override
    public void loadExternalExtensions(Context context) {
        FlutterBitmapUtils.extendCapabilities();
        BackgroundExecutor.setBackgroundExecutorClass(DartBackgroundExecutor.class);
    }
}