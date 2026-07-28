/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.advanced;

import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.provider.Settings;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.bytedance.vepicutureinpicture.VeLivePictureInPicturePlayerManager;
import com.bytedance.vepicutureinpicture.VePictureInPictureManager;
import com.ss.videoarch.liveplayer.VeLivePayerAudioLoudnessInfo;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioVolume;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame;
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerError;
import com.ss.videoarch.liveplayer.VeLivePlayerObserver;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;
import com.ss.videoarch.liveplayer.VideoLiveManager;
import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.features.advanced.pip.FloatingVideoService;
import com.ttsdk.quickstart.features.basic.PullStreamActivity;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ttsdk.quickstart.helper.sign.VeLiveURLGenerator;
import com.ttsdk.quickstart.helper.sign.model.VeLivePullURLModel;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLError;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLRootModel;

import org.json.JSONObject;

import java.nio.ByteBuffer;

public class PictureInPictureActivity extends AppCompatActivity {
    private final String TAG = "PictureInPicture";
    private VeLivePlayer mLivePlayer;
    private TextView mInfoView;

    private EditText mUrlText;

    private SurfaceView mSurfaceView;
    private FrameLayout mViewContainer;
    private VeLivePictureInPicturePlayerManager mPipManager;
    private boolean isBackPressed;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_picture_in_picture);

        mInfoView = findViewById(R.id.pull_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        mSurfaceView = new SurfaceView(this);
        mSurfaceView.getHolder().setFormat(PixelFormat.RGBA_8888);
        mViewContainer = findViewById(R.id.surface_container);
        mViewContainer.addView(mSurfaceView);
        setupLivePlayer();

        setupPictureInPicture();
    }

    private void setupPictureInPicture() {
        mPipManager = new VeLivePictureInPicturePlayerManager(mLivePlayer, this);
        mPipManager.setObserver(new VeLivePictureInPicturePlayerManager.VeLivePictureInPicturePlayerManagerObserver() {
            @Override
            public void onClickResumeAction() {
                // Resume from PiP
                try {
                    Class<?> cls = Class.forName(PictureInPictureActivity.class.getName());
                    Intent intent = new Intent(getBaseContext(), cls);
                    intent.setFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                } catch (ClassNotFoundException e) {

                }
            }
        });
        boolean isPermission = mPipManager.isPermissionGranted();
        if (!isPermission) {
            mPipManager.requestPermission(new VePictureInPictureManager.VePictureInPicturePermissionCallback() {
                @Override
                public void onGranted(boolean granted) {
                    //on permission granted
                }

                @Override
                public void onRequestPermission(Context context, VePictureInPictureManager.VePictureInPicturePermissionResult result) {
                    // on request permission
                    new AlertDialog.Builder(context)
                            .setMessage("尚未开启系统悬浮窗，请去设置中开启 [显示悬浮窗] 权限")
                            .setPositiveButton("去开启", (dialog, which) -> {
                                // 用户同意开启
                                result.accept();
                            })
                            .setNegativeButton("取消", (dialog, which) -> {
                                // 用户未同意
                                result.cancel();
                            })
                            .setCancelable(false)
                            .show();
                }
            });
        }

        mPipManager.setSurfaceHolder(mSurfaceView.getHolder());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //  Destroy the live stream player
        //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
        mLivePlayer.destroy();
        if (mPipManager != null) {
            mPipManager.destroy();
        }
    }

    private void setupLivePlayer() {
        //  Create a live stream player
        mLivePlayer = new VideoLiveManager(this);

        //  Set player callback
        mLivePlayer.setObserver(mplayerObserver);

        //  Configure the player
        VeLivePlayerConfiguration config = new VeLivePlayerConfiguration();
        //  Whether to enable periodic information callbacks
        config.enableStatisticsCallback = true;
        //  Periodic information callback interval
        config.statisticsCallbackInterval = 1;
        //  Whether to enable internal DNS resolution
        config.enableLiveDNS = true;

        //  Configure the pull stream player
        mLivePlayer.setConfig(config);

        //  Set preview view
        mLivePlayer.setSurfaceHolder(mSurfaceView.getHolder());

        //  Set render fill mode
        mLivePlayer.setRenderFillMode(VeLivePlayerFillModeAspectFill);
    }


    public void playControl(View view) {
        ToggleButton toggleButton = (ToggleButton) view;
        if (mUrlText.getText().toString().isEmpty()) {
            toggleButton.setChecked(false);
            mInfoView.setText(R.string.config_stream_name_tip);
            return;
        }
        if (toggleButton.isChecked()) {
            view.setEnabled(false);
            mInfoView.setText(R.string.Generate_Pull_Url_Tip);
            VeLiveURLGenerator.genPullUrl(VeLiveSDKHelper.LIVE_APP_NAME, mUrlText.getText().toString(), new VeLiveURLGenerator.VeLiveURLCallback<VeLivePullURLModel>() {
                @Override
                public void onSuccess(VeLiveURLRootModel<VeLivePullURLModel> model) {
                    view.setEnabled(true);
                    mInfoView.setText("");

                    //  Set broadcast address, support rtmp, http, https protocol, flv, m3u8 format address
                    mLivePlayer.setPlayUrl(model.result.getUrl("flv"));

                    //  Start playing
                    mLivePlayer.play();
                }

                @Override
                public void onFailed(VeLiveURLError error) {
                    view.setEnabled(true);
                    mInfoView.setText(error.message);
                    toggleButton.setChecked(false);
                }
            });
        } else {
            //  Stop playing
            mLivePlayer.stop();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (mPipManager != null && !isBackPressed) {
            mPipManager.startPictureInPicture();
        }
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        isBackPressed = true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (mPipManager != null) {
            mPipManager.stopPictureInPicture();
        }
    }

    private final VeLivePlayerObserver mplayerObserver = new VeLivePlayerObserver() {
        @Override
        public void onError(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {
            Log.e("VeLiveQuickStartDemo", "Player Error" + veLivePlayerError.mErrorMsg);
        }
        @Override
        public void onStatistics(VeLivePlayer veLivePlayer, VeLivePlayerStatistics veLivePlayerStatistics) {
            runOnUiThread(() -> mInfoView.setText(VeLiveSDKHelper.getPlaybackInfoString(veLivePlayerStatistics)));
        }
        @Override
        public void onFirstVideoFrameRender(VeLivePlayer veLivePlayer, boolean b) {

        }

        @Override
        public void onFirstAudioFrameRender(VeLivePlayer veLivePlayer, boolean b) {

        }

        @Override
        public void onStallStart(VeLivePlayer veLivePlayer) {

        }

        @Override
        public void onStallEnd(VeLivePlayer veLivePlayer) {

        }

        @Override
        public void onVideoRenderStall(VeLivePlayer veLivePlayer, long l) {

        }

        @Override
        public void onAudioRenderStall(VeLivePlayer veLivePlayer, long l) {

        }

        @Override
        public void onResolutionSwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution, VeLivePlayerError veLivePlayerError, VeLivePlayerDef.VeLivePlayerResolutionSwitchReason veLivePlayerResolutionSwitchReason) {

        }

        @Override
        public void onVideoSizeChanged(VeLivePlayer veLivePlayer, int width, int height) {
            if (mPipManager != null) {
                mPipManager.setVideoSize(width, height);
            }
        }

        @Override
        public void onReceiveSeiMessage(VeLivePlayer veLivePlayer, String s) {

        }

        @Override
        public void onMainBackupSwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerStreamType veLivePlayerStreamType, VeLivePlayerError veLivePlayerError) {

        }

        @Override
        public void onPlayerStatusUpdate(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerStatus veLivePlayerStatus) {

        }

        @Override
        public void onSnapshotComplete(VeLivePlayer veLivePlayer, Bitmap bitmap) {

        }

        @Override
        public void onRenderVideoFrame(VeLivePlayer veLivePlayer, VeLivePlayerVideoFrame veLivePlayerVideoFrame) {

        }

        @Override
        public void onRenderAudioFrame(VeLivePlayer veLivePlayer, VeLivePlayerAudioFrame veLivePlayerAudioFrame) {

        }

        @Override
        public void onStreamFailedOpenSuperResolution(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {

        }

        @Override
        public void onAudioDeviceOpen(VeLivePlayer veLivePlayer, int i, int i1, int i2) {

        }

        @Override
        public void onAudioDeviceClose(VeLivePlayer veLivePlayer) {

        }

        @Override
        public void onAudioDeviceRelease(VeLivePlayer veLivePlayer) {

        }

        @Override
        public void onBinarySeiUpdate(VeLivePlayer veLivePlayer, ByteBuffer byteBuffer) {

        }

        @Override
        public void onMonitorLog(VeLivePlayer veLivePlayer, JSONObject jsonObject, String s) {

        }

        @Override
        public void onReportALog(VeLivePlayer veLivePlayer, int i, String s) {

        }

        @Override
        public void onResolutionDegrade(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution) {

        }

        @Override
        public void onTextureRenderDrawFrame(VeLivePlayer veLivePlayer, Surface surface) {

        }

        @Override
        public void onHeadPoseUpdate(VeLivePlayer veLivePlayer, float v, float v1, float v2, float v3, float v4, float v5, float v6) {

        }

        @Override
        public void onResponseSmoothSwitch(VeLivePlayer veLivePlayer, boolean b, int i) {

        }

        @Override
        public void onNetworkQualityChanged(VeLivePlayer veLivePlayer, int i, String s) {

        }

        @Override
        public void onAudioVolume(VeLivePlayer veLivePlayer, VeLivePlayerAudioVolume veLivePayerAudioVolume) {

        }

        @Override
        public void onLoudness(VeLivePlayer veLivePlayer, VeLivePayerAudioLoudnessInfo veLivePayerAudioLoudnessInfo) {

        }

        @Override
        public void onStreamFailedOpenSharpen(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {

        }

        @Override
        public SwitchPermissionRequestResult shouldAutomaticallySwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution1, JSONObject jsonObject) {
            return SwitchPermissionRequestResult.APPROVED;
        }

        @Override
        public void didAutomaticallySwitch(VeLivePlayer veLivePlayer, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution, VeLivePlayerDef.VeLivePlayerResolution veLivePlayerResolution1, JSONObject jsonObject) {

        }
    };

}