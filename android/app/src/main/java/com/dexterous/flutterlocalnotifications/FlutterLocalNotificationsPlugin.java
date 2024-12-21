package com.dexterous.flutterlocalnotifications;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import androidx.core.app.NotificationCompat.BigPictureStyle;

public class FlutterLocalNotificationsPlugin {
    private void setBigPictureStyle(BigPictureStyle bigPictureStyle) {
        // Explicitly cast null to Bitmap to resolve the ambiguity
        bigPictureStyle.bigLargeIcon((Bitmap) null);
    }
}
