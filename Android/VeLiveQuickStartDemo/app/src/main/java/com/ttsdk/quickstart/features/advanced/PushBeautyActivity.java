/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.advanced;

import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureFrontCamera;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ToggleButton;

import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.helper.VeLiveEffectHelper;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherConfiguration;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLivePusherObserver;
import com.ss.avframework.live.VeLiveVideoEffectManager;

/*
Camera push streaming, integrated intelligent beautification special effects

 This file shows how to integrate camera push streaming and intelligent beautification special effects
 1. First integrate the intelligent beautification special effects SDK, and recommend integrating the dynamic library
 2. Initialize the push streamer API:
 VeLivePusherConfiguration config = new VeLivePusherConfiguration ();
 config.setContext (this);
 mLivePusher = config.build ();
 3. Set the preview view API: mLivePusher.setRenderView (findViewById (R.id render_view));
 4. Open the microphone capture API: mLivePusher.startVideoCapture (VeLiveVideoCaptureFrontCamera);
 5. Open the camera capture API: mLivePusher.startVideoCapture (VeLiveVideoCaptureFrontCamera);
 6, start streaming API: [mLivePusherstartPush: @"rtmp://push.example.com/rtmp"];
 7, initial beauty related parameters API: mLivePusher.getVideoEffectManager ().setupWithConfig (new VeLiveVideoEffectLicenseConfiguration.create ("licpath
 8、set the model effect API: mLivePusher.getVideoEffectManager().setAlgoModelPath(algoModelPath);
 9、Setup Beauty API: mLivePusher.getVideoEffectManager().setComposeNodes(nodes);
 10、Setup Filter API: mLivePusher.getVideoEffectManager().setFilter("");
 11、Setup Sticker API:  mLivePusher.getVideoEffectManager().setSticker("");
 */
public class PushBeautyActivity extends AppCompatActivity {
    private VeLivePusher mLivePusher;
    private EditText mUrlText;
    private TextView mInfoView;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_push_beauty);
        mInfoView = findViewById(R.id.push_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        mUrlText.setText(VeLiveSDKHelper.LIVE_PUSH_URL);
        setupLivePusher();
        setupEffectSDK();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //  Destroy the thruster
        //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
        mLivePusher.release();
    }

    private void setupLivePusher() {
        //  Push stream configuration
        VeLivePusherConfiguration config = new VeLivePusherConfiguration();
        //  Configure context
        config.setContext(this);
        //  Number of failed reconnections
        config.setReconnectCount(10);
        //  Create a pusher
        mLivePusher = config.build();
        //  Configure preview view
        mLivePusher.setRenderView(findViewById(R.id.render_view));
        //  Set the pusher callback
        mLivePusher.setObserver(pusherObserver);
        //  Set periodic information callbacks
        mLivePusher.setStatisticsObserver(statisticsObserver, 3);
        //  Start video capture
        mLivePusher.startVideoCapture(VeLiveVideoCaptureFrontCamera);
        //  Start audio capture
        mLivePusher.startAudioCapture(VeLiveAudioCaptureMicrophone);
    }


    public void pushControl(View view) {
        ToggleButton toggleButton = (ToggleButton)view;
        if (mUrlText.getText().toString().isEmpty()) {
            Log.e("VeLiveQuickStartDemo", "Please Config Url");
            return;
        }
        if (toggleButton.isChecked()) {
            //  Start pushing the stream, push the stream address support: rtmp protocol, http protocol (RTM)
            mLivePusher.startPush(mUrlText.getText().toString());
        } else {
            //  Stop streaming
            mLivePusher.stopPush();
        }
    }

    public void setupEffectSDK() {
        //  Note: This method only takes effect when the SDK of intelligent beautification special effects has been integrated in the project
        VeLiveVideoEffectManager effectManager = mLivePusher.getVideoEffectManager();
        //  Effects Authentication License path, please find the correct path according to the project configuration
        String licPath = VeLiveEffectHelper.getLicensePath("xxx.licbag");
        //  Effect model effect package path
        String algoModePath = VeLiveEffectHelper.getModelPath();
        if (!VeLiveSDKHelper.isFileExists(licPath)) {
            return;
        }
        //  Create Beauty Configuration
        VeLivePusherDef.VeLiveVideoEffectLicenseConfiguration licConfig = VeLivePusherDef.VeLiveVideoEffectLicenseConfiguration.create(licPath);
        //  Set Beauty Configuration
        effectManager.setupWithConfig(licConfig);
        //  Set algorithm package path
        effectManager.setAlgorithmModelPath(algoModePath);
        //  Turn on beauty effects
        effectManager.setEnable(true, new VeLivePusherDef.VeLiveVideoEffectCallback() {
            @Override
            public void onResult(int result, String msg) {
                if (result != 0) {
                    Log.e("VeLiveQuickStartDemo", "Effect init error:" + msg);
                }
            }
        });
    }

    public void beautyControl(View view) {
        //  According to the effect package, find the correct resource path, generally to the reshape_lite, beauty_IOS_lite directory
        String beautyPath = VeLiveEffectHelper.getBeautyPathByName("xxx");
        if (!VeLiveSDKHelper.isFileExists(beautyPath)) {
            return;
        }
        //  Set up beauty effect package
        mLivePusher.getVideoEffectManager().setComposeNodes(new String[]{ beautyPath });
        //  Set the beauty effect intensity, NodeKey can be obtained in the config_file under the effect package, if there is no config_file, please contact the business consultation
        mLivePusher.getVideoEffectManager().updateComposerNodeIntensity(beautyPath, "whiten", 0.5F);
    }

    public void filterControl(View view) {
        //  Filter effect package, find the correct resource path, generally to the Filter_01_xx directory
        String filterPath = VeLiveEffectHelper.getFilterPathByName("xxx");;
        //  Set the filter effect package path
        mLivePusher.getVideoEffectManager().setFilter(filterPath);
        //  Set filter effect intensity
        mLivePusher.getVideoEffectManager().updateFilterIntensity(0.5F);
    }

    public void stickerControl(View view) {
        //  Sticker effect package, find the correct resource path, generally to the stickers_xxx directory
        String stickerPath = VeLiveEffectHelper.getStickerPathByName("xxx");
        //  Set the sticker effect package path
        mLivePusher.getVideoEffectManager().setSticker(stickerPath);
    }

    private VeLivePusherObserver pusherObserver = new VeLivePusherObserver() {
        @Override
        public void onError(int code, int subCode, String msg) {
            Log.d("VeLiveQuickStartDemo", "Error" + code + subCode + msg);
        }

        @Override
        public void onStatusChange(VeLivePusherDef.VeLivePusherStatus status) {
            Log.d("VeLiveQuickStartDemo", "Status" + status);
        }
    };

    private VeLivePusherDef.VeLivePusherStatisticsObserver statisticsObserver = new VeLivePusherDef.VeLivePusherStatisticsObserver() {
        @Override
        public void onStatistics(VeLivePusherDef.VeLivePusherStatistics statistics) {
            runOnUiThread(() -> mInfoView.setText(VeLiveSDKHelper.getPushInfoString(statistics)));
        }
    };

}
