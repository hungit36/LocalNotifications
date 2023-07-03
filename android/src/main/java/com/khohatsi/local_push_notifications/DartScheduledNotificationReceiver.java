package com.khohatsi.local_push_notifications;

import android.content.Context;

import com.khohatsi.local_push_notifications.core.broadcasters.receivers.ScheduledNotificationReceiver;

public class DartScheduledNotificationReceiver extends ScheduledNotificationReceiver {
    @Override
    public void initializeExternalPlugins(Context context) throws Exception {
        LocalNotificationsFlutterExtension.initialize();
    }
}
