/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.helper;
/*
 This file stores the basic configuration information of the SDK, regardless of the information. It can be modified on the interface when entering the corresponding page.
 This file stores the basic configuration information of the SDK, including SDK AppID, License file name, up & down streaming address, and Lianmai interactive room ID., live streaming host/viewer UID and temporary Token
 SDK configuration information application: https://console.volcengine.com/live/main/sdk
  up & down streaming address generation reference document: https://console.volcengine.com/live/main/locationGenerate
 Interactive live broadcast related reference document: https://console.volcengine.com/rtc/listRTC
 */

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.ttsdk.quickstart.R;
import com.pandora.common.env.Env;
import com.pandora.common.env.config.Config;
import com.pandora.common.env.config.LogConfig;
import com.pandora.ttlicense2.LicenseManager;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class VeLiveSDKHelper {

    // AppID
    public static String TTSDK_APP_ID = "";
    /*
     License name, the current Demo file is stored in the same directory as this file. If you do SDK quick verification, you can directly replace the content of the ttsdk.lic file
     */
    public static String TTSDK_LICENSE_NAME = "ttsdk.lic";

    /*
     RTMP, RTM, Quic push stream address
      generation method: generate https://console.volcengine.com/live/main/locationGenerate through the console
     */
    public static String LIVE_PUSH_URL = "";
    public static String LIVE_RTM_PUSH_URL = "";

    /*
     RTM, rtmp, flv, m3u8 pull stream address
      generation method: generate https://console.volcengine.com/live/main/locationGenerate through the console
     */
    public static String LIVE_PULL_URL = "";
    public static String LIVE_RTM_PULL_URL = "";


    /*
     Interactive Live AppID
     */
    public static String RTC_APPID = "";

    /*
     Interactive live streaming host room ID
     */
    public static String RTC_ROOM_ID = "";

    /*
     Interactive live streaming host user ID
     */
    public static String RTC_USER_ID = "";

    /*
     Interactive live streaming host user Token
     Generation method: use live streaming host room ID and live streaming host user ID to generate
     https://console.volcengine.com/rtc/listRTC in the RTC console
     */
    public static String RTC_USER_TOKEN = "";

    /*
     When live streaming host and live streaming host PK, the room ID of the other live streaming host
     */
    public static String RTC_OTHER_ROOM_ID = "";

    /*
     When live streaming host and live streaming host PK, the current live streaming host joins the token
      generation method in the other party's live streaming host room: use the user ID of the current live streaming host and the room ID of the other party's live streaming host to generate it in the console
     */
    public static String RTC_OTHER_ROOM_TOKEN = "";

    private static Context sAppContext;

    public static void initTTSDK(final Context context) {
        sAppContext = context;

        LogConfig.Builder logBuilder = new LogConfig.Builder(context);
        //  Whether to output logs to the console
        logBuilder.setEnableConsole(true);
        //  Whether to write log to file
        logBuilder.setEnableLogFile(true);
        //  Current device unique ID
        logBuilder.setDeviceID(Settings.System.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID));
        //  Maximum file size in MB
        logBuilder.setMaxLogSizeM(10);
        //  Single file size in MB
        logBuilder.setSingleLogSizeM(1);
        //  File expiration time, in seconds
        logBuilder.setLogExpireTimeS(24 * 60 * 60);
        //  log output level
        logBuilder.setLogLevel(LogConfig.LogLevel.Debug);

        Config.Builder configBuilder = new  Config.Builder();
        //  Configure App Context
        configBuilder.setApplicationContext(context);
        //  Channel configuration, general transmission and distribution type, closed beta, public beta, online, etc
        configBuilder.setAppChannel("GoogleStore");
        //  App name
        configBuilder.setAppName(getAppName(context));
        //  Configure the service area, the default CN
        configBuilder.setAppRegion("sg");

        //  version number
        configBuilder.setAppVersion(getVersionName(context));
        //  Configuration log
        configBuilder.setLogConfig(logBuilder.build());
        //  Configure TTSDK AppID
        configBuilder.setAppID(TTSDK_APP_ID);
        //  Configure the License Path
        configBuilder.setLicenseUri("assets:///" + TTSDK_LICENSE_NAME);
        //  Configure License Resolution Callback
        configBuilder.setLicenseCallback(mLicenseCallback);
        //  Initial SDK
        Env.init(configBuilder.build());

        VeLiveEffectHelper.initVideoEffectResource();
    }

    private static final LicenseManager.Callback mLicenseCallback = new LicenseManager.Callback() {
        @Override
        public void onLicenseLoadSuccess(@NonNull String licenseUri, @NonNull String licenseId) {
            Log.e("VeLiveQuickStartDemo", "License Load Success" + licenseId);
        }
        @Override
        public void onLicenseLoadError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {
            Log.e("VeLiveQuickStartDemo", "License Load Error" + e);
        }
        @Override
        public void onLicenseLoadRetry(@NonNull String licenseUri) {

        }
        @Override
        public void onLicenseUpdateSuccess(@NonNull String licenseUri, @NonNull String licenseId) {

        }
        @Override
        public void onLicenseUpdateError(@NonNull String licenseUri, @NonNull Exception e, boolean retryAble) {

        }
        @Override
        public void onLicenseUpdateRetry(@NonNull String licenseUri) {

        }
    };

    static private String getInfoString(int resId, Object value, String end) {
        return sAppContext.getString(resId) + ":" + value + end;
    }

    static public String getPushInfoString(VeLivePusherDef.VeLivePusherStatistics statistics) {
        String infoStr = "";
        infoStr += getInfoString(R.string.Camera_Push_Info_Url, statistics.url, "\n");
        infoStr += getInfoString(R.string.Camera_Push_Info_Video_MaxBitrate, statistics.maxVideoBitrate / 1000, " kbps ");
        infoStr += getInfoString(R.string.Camera_Push_Info_Video_StartBitrate, statistics.videoBitrate / 1000, " kbps\n");
        infoStr += getInfoString(R.string.Camera_Push_Info_Video_MinBitrate, statistics.minVideoBitrate / 1000, " kbps ");
        infoStr += getInfoString(R.string.Camera_Push_Info_Video_Capture_Resolution, statistics.captureWidth + ", " + statistics.captureHeight, "\n");

        infoStr += getInfoString(R.string.Camera_Push_Info_Video_Push_Resolution, statistics.encodeWidth + ", " + statistics.encodeHeight, " ");
        infoStr += getInfoString(R.string.Camera_Push_Info_Video_Capture_FPS, (int)statistics.captureFps, "\n");

        infoStr += getInfoString(R.string.Camera_Push_Info_Video_Capture_IO_FPS, (int)statistics.captureFps + "/" + (int)statistics.encodeFps, " ");

        infoStr += getInfoString(R.string.Camera_Push_Info_Video_Encode_Codec, statistics.codec, "\n");

        infoStr += getInfoString(R.string.Camera_Push_Info_Real_Time_Trans_FPS, (int)statistics.transportFps, "\n");
        infoStr += getInfoString(R.string.Camera_Push_Info_Real_Time_Encode_Bitrate, (int)(statistics.encodeVideoBitrate / 1000), " kbps ");
        infoStr += getInfoString(R.string.Camera_Push_Info_Real_Time_Trans_Bitrate, (int)(statistics.transportVideoBitrate / 1000), " kbps ");
        return infoStr;
    }

    static public String getPlaybackInfoString(VeLivePlayerStatistics statistics) {
        String infoStr = "";
        infoStr += getInfoString(R.string.Pull_Stream_Info_Url, statistics.url, "\n");
        String videoSize = "width:" + statistics.width + "height:" + statistics.height;
        infoStr += getInfoString(R.string.Pull_Stream_Info_Video_Size, videoSize, "\n");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Video_FPS, (int)statistics.fps, " ");
        infoStr += getInfoString(R.string.Pull_Stream_Info_Video_Bitrate, statistics.bitrate, " kbps\n");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Video_BufferTime, statistics.videoBufferMs, "ms ");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Audio_BufferTime, statistics.audioBufferMs, " ms\n");
        infoStr += getInfoString(R.string.Pull_Stream_Info_Stream_Format, statistics.format, " ");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Stream_Protocol, statistics.protocol, "\n");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Video_Codec, statistics.videoCodec, "\n");

        infoStr += getInfoString(R.string.Pull_Stream_Info_Delay_Time, statistics.delayMs, "ms ");
        infoStr += getInfoString(R.string.Pull_Stream_Info_Stall_Time, statistics.stallTimeMs, " ms\n");
        infoStr += getInfoString(R.string.Pull_Stream_Info_Is_HardWareDecode, statistics.isHardwareDecode, " ");
        return infoStr;
    }

    static public boolean isFileExists(String filePath) {
        if (filePath == null) {
            return false;
        }
        try {
            File file = new File(filePath);
            return file.exists();
        } catch (Exception e) {
            return false;
        }
    }

    static public boolean checkPermission(Activity activity, int request) {
        String[] permissions = new String[]{
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO,
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.MODIFY_AUDIO_SETTINGS,
                Manifest.permission.ACCESS_NETWORK_STATE,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE
        };
        List<String> permissionList = new ArrayList<>();
        for (String permission : permissions) {
            boolean granted = ContextCompat.checkSelfPermission(sAppContext, permission) == PackageManager.PERMISSION_GRANTED;
            if (granted) continue;
            permissionList.add(permission);
        }
        if (permissionList.isEmpty()) return true;
        String[] permissionsToGrant = new String[permissionList.size()];
        permissionList.toArray(permissionsToGrant);
        ActivityCompat.requestPermissions(activity, permissionsToGrant, request);
        return false;
    }

    /**
     * Get application name
     */
    public static synchronized String getAppName(Context context) {
        try {
            PackageManager packageManager = context.getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageInfo(
                    context.getPackageName(), 0);
            int labelRes = packageInfo.applicationInfo.labelRes;
            return context.getResources().getString(labelRes);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * [Get application version name information]
     * @param context
     * @return The version name of the current application
     */
    public static synchronized String getVersionName(Context context) {
        try {
            PackageManager packageManager = context.getPackageManager();
            PackageInfo packageInfo = packageManager.getPackageInfo(
                    context.getPackageName(), 0);
            return packageInfo.versionName;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
