package com.khohatsi.local_push_notifications;

import android.content.Context;

import com.khohatsi.local_push_notifications.core.broadcasters.receivers.RefreshSchedulesReceiver;

public class DartRefreshSchedulesReceiver extends RefreshSchedulesReceiver {

    @Override
    public void initializeExternalPlugins(Context context) throws Exception {
        LocalNotificationsFlutterExtension.initialize();
    }
}
