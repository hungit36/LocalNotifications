package com.khohatsi.local_push_notifications;

import android.content.Context;

import com.khohatsi.local_push_notifications.core.services.LocalBackgroundService;

public class DartBackgroundService extends LocalBackgroundService {

    @Override
    public void initializeExternalPlugins(Context context) throws Exception {
        LocalNotificationsFlutterExtension.initialize();
    }
}
