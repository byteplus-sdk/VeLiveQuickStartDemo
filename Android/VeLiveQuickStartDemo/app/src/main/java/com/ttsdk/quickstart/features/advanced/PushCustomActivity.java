/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.advanced;

import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureExternal;

import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ToggleButton;

import androidx.appcompat.app.AppCompatActivity;

import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.helper.VeLiveDeviceCapture;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherConfiguration;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLivePusherObserver;
import com.ss.avframework.live.VeLiveVideoFrame;
import com.ss.avframework.utils.TimeUtils;

public class PushCustomActivity extends AppCompatActivity {

    private VeLiveDeviceCapture mDeviceCapture;
    private VeLivePusher mLivePusher;
    private EditText mUrlText;
    private TextView mInfoView;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_push_custom);
        mInfoView = findViewById(R.id.push_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        mUrlText.setText(VeLiveSDKHelper.LIVE_PUSH_URL);
        setupLivePusher();
        setupCustomCamera();
    }
    @Override
    protected void onDestroy() {
        super.onDestroy();
        //  Destroy the thruster
        //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
        mLivePusher.release();
        mDeviceCapture.stop();
    }

    private void setupLivePusher() {
        //  Push stream configuration
        VeLivePusherConfiguration config = new VeLivePusherConfiguration();
        //  Configure context
        config.setContext(this);
        //  Number of failed reconnections
        config.setReconnectCount(10);
        //  Video encoding configuration
        VeLivePusherDef.VeLiveVideoEncoderConfiguration encoderConfiguration = new VeLivePusherDef.VeLiveVideoEncoderConfiguration();
        //  Set the video resolution, and the best bit rate parameters will be set internally according to the resolution
        encoderConfiguration.setResolution(VeLivePusherDef.VeLiveVideoResolution.VeLiveVideoResolution720P);
        //  Video encoding initialization bit rate (for reference only)
        encoderConfiguration.setBitrate(1200);
        //  Video encoding maximum bit rate (for reference only)
        encoderConfiguration.setMaxBitrate(1900);
        //  Minimum bit rate for video encoding (for reference only)
        encoderConfiguration.setMinBitrate(800);
        //  Create a pusher
        mLivePusher = config.build();
        //  Configuration coding
        mLivePusher.setVideoEncoderConfiguration(encoderConfiguration);
        //  Adjust bit rate adaptive sensitivity, CLOSE, NORMAL, SENSITIVE, MORE_SENSITIVE
        mLivePusher.setProperty("VeLiveKeySetBitrateAdaptStrategy", "NORMAL");
        //  Configure preview view
        mLivePusher.setRenderView(findViewById(R.id.render_view));
        //  Set the pusher callback
        mLivePusher.setObserver(pusherObserver);
        //  Set periodic information callbacks
        mLivePusher.setStatisticsObserver(statisticsObserver, 3);
        //  Start video capture
        mLivePusher.startVideoCapture(VeLiveVideoCaptureExternal);
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

    private final VeLivePusherObserver pusherObserver = new VeLivePusherObserver() {
        @Override
        public void onError(int code, int subCode, String msg) {
            Log.d("VeLiveQuickStartDemo", "Error" + code + subCode + msg);
        }

        @Override
        public void onStatusChange(VeLivePusherDef.VeLivePusherStatus status) {
            Log.d("VeLiveQuickStartDemo", "Status" + status);
        }
    };

    private final VeLivePusherDef.VeLivePusherStatisticsObserver statisticsObserver = new VeLivePusherDef.VeLivePusherStatisticsObserver() {
        @Override
        public void onStatistics(VeLivePusherDef.VeLivePusherStatistics statistics) {
            runOnUiThread(() -> mInfoView.setText(VeLiveSDKHelper.getPushInfoString(statistics)));
        }
    };
    private void setupCustomCamera() {
        mDeviceCapture = new VeLiveDeviceCapture();
        mDeviceCapture.start((data, width, height) -> {
            VeLiveVideoFrame videoFrame =  new VeLiveVideoFrame(width, height, TimeUtils.currentTimeUs(), data);
            videoFrame.setReleaseCallback(videoFrame::release);
            mLivePusher.pushExternalVideoFrame(videoFrame);
        });
    }
}