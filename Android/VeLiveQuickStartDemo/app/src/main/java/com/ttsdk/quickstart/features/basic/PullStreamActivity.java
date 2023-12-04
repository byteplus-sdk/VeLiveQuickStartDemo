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
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ToggleButton;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

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

    private VeLivePlayer mLivePlayer;
    private TextView mTextView;

    private EditText mUrlText;

    private SurfaceView mSurfaceView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pull_stream);
        mTextView = findViewById(R.id.pull_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        mUrlText.setText(VeLiveSDKHelper.LIVE_PULL_URL);
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

        //  Set broadcast address, support rtmp, http, https protocol, flv, m3u8 format address
        mLivePlayer.setPlayUrl(mUrlText.getText().toString());


        //  To configure the RTM low-latency address, refer to the following code
       /*
        //Configure RTM home address
        VeLivePlayerStreamData. VeLivePlayerStream playStreamRTM = new VeLivePlayerStreamData. VeLivePlayerStream ();
        playStreamRTM.url = Constant.LIVE_PULL_RTM_URL;
        playStreamRTM.format = VeLivePlayerFormatRTM;
        playStreamRTM.resolution = VeLivePlayerResolutionOrigin;
        playStreamRTM.streamType = VeLivePlayerStreamTypeMain;

        //Configure Flv downgrade address
        VeLivePlayerStreamData. VeLivePlayerStream playStreamFLV = new VeLivePlayerStreamData. VeLivePlayerStream ();
        playStreamFLV.url = Constant.LIVE_PULL_URL;
        playStreamFLV.format = VeLivePlayerFormatFLV;
        playStreamFLV.resolution = VeLivePlayerResolutionOrigin;
        playStreamFLV.streamType = VeLi = new VeLivePlayerStreamData ();

        List < VeLivePlayerStreamData. VeLivePlayerStream > streamList = new ArrayList <>();
        //add RTM master address
        streamList.add (playStreamRTM);
        //add FLV downgrade address
        streamList.add (playStreamFLV);
        streamData.mainStreamList = streamList;
        str

        streamData.mainStreamList = streamList;
        streamData.defaultFormat = VeLivePlayerFormatRTM;
        streamData.defaultProtocol = VeLivePlayerFormatTLS;
        mLivePlayer.setPlayStreamData(streamData);
        */

        //  Start playing
        mLivePlayer.play();
    }


    public void playControl(View view) {
        ToggleButton toggleButton = (ToggleButton) view;
        if (toggleButton.isChecked()) {
            //  Start playing
            mLivePlayer.play();
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
            Log.e("VeLiveQuickStartDemo", "Player Error" + veLivePlayerError.mErrorMsg);
        }
        @Override
        public void onStatistics(VeLivePlayer veLivePlayer, VeLivePlayerStatistics veLivePlayerStatistics) {
            runOnUiThread(() -> mTextView.setText(VeLiveSDKHelper.getPlaybackInfoString(veLivePlayerStatistics)));
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