/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.basic;

import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFill;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeAspectFit;
import static com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode.VeLivePlayerFillModeFullFill;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ToggleButton;


import com.ss.videoarch.liveplayer.VeLivePayerAudioLoudnessInfo;
import com.ss.videoarch.liveplayer.VeLivePayerAudioVolume;
import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ss.videoarch.liveplayer.VeLivePlayer;
import com.ss.videoarch.liveplayer.VeLivePlayerAudioFrame;
import com.ss.videoarch.liveplayer.VeLivePlayerConfiguration;
import com.ss.videoarch.liveplayer.VeLivePlayerDef;
import com.ss.videoarch.liveplayer.VeLivePlayerDef.VeLivePlayerFillMode;
import com.ss.videoarch.liveplayer.VeLivePlayerError;
import com.ss.videoarch.liveplayer.VeLivePlayerObserver;
import com.ss.videoarch.liveplayer.VeLivePlayerStatistics;
import com.ss.videoarch.liveplayer.VeLivePlayerVideoFrame;
import com.ss.videoarch.liveplayer.VideoLiveManager;
import com.ttsdk.quickstart.helper.sign.VeLiveURLGenerator;
import com.ttsdk.quickstart.helper.sign.model.VeLivePullURLModel;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLError;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLRootModel;

import org.json.JSONObject;

import java.nio.ByteBuffer;

/*
Live streaming
 This file shows how to integrate live streaming function
 1, initialize the pusher API: mLivePlayer = new VideoLiveManager (this);
 2, configure the pusher API: mLivePlayer.setConfig (new VeLivePlayerConfiguration ());
 3, configure the rendering view API: mLivePlayer.setSurfaceHolder (mSurfaceView.getHolder ());
 4, configure the broadcast address API: mLivePlayer.setPlayUrl ("http://pull.example.com/pull.flv");
 5, start playing API: mLivePlayer.play ();
 */
public class PullStreamActivity extends AppCompatActivity {
    private final String TAG = "PullStreamActivity";

    private VeLivePlayer mLivePlayer;
    private TextView mInfoView;

    private EditText mUrlText;

    private SurfaceView mSurfaceView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_pull_stream);
        mInfoView = findViewById(R.id.pull_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        mSurfaceView = findViewById(R.id.render_view);
        setupLivePlayer();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //  Destroy the live stream player
        //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
        mLivePlayer.destroy();
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

    public void fillModeControl(View view) {
        showFillModeDialog();
    }

    private void changeFillMode(VeLivePlayerFillMode fillMode) {
        //  Set fill mode
        mLivePlayer.setRenderFillMode(fillMode);
    }

    public void muteControl(View view) {
        //  Mute/Unmute
        ToggleButton toggleButton = (ToggleButton) view;
        mLivePlayer.setMute(toggleButton.isChecked());
    }

    private VeLivePlayerObserver mplayerObserver = new VeLivePlayerObserver() {
        @Override
        public void onError(VeLivePlayer veLivePlayer, VeLivePlayerError veLivePlayerError) {
            Log.e(TAG, "Player Error" + veLivePlayerError.mErrorMsg);
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
        public void onVideoSizeChanged(VeLivePlayer veLivePlayer, int i, int i1) {

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
        public void onAudioVolume(VeLivePlayer veLivePlayer, VeLivePayerAudioVolume veLivePayerAudioVolume) {

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

    private void showFillModeDialog() {
        final String[] items = {
                getString(R.string.Pull_Stream_Fill_Mode_Alert_AspectFill),
                getString(R.string.Pull_Stream_Fill_Mode_Alert_AspectFit),
                getString(R.string.Pull_Stream_Fill_Mode_Alert_FullFill)};
        AlertDialog.Builder singleChoiceDialog = new AlertDialog.Builder(this);
        singleChoiceDialog.setTitle(getString(R.string.Pull_Stream_Fill_Mode_Alert_Title));
        singleChoiceDialog.setItems(items, ((dialog, which) -> {
            if (which == 0) {
                changeFillMode(VeLivePlayerFillModeAspectFill);
            } else if (which == 1) {
                changeFillMode(VeLivePlayerFillModeAspectFit);
            } else if (which == 2) {
                changeFillMode(VeLivePlayerFillModeFullFill);
            }
        }));
        singleChoiceDialog.show();
    }

}