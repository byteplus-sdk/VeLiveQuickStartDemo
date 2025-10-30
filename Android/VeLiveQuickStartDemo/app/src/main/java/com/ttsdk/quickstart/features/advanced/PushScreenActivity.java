/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.advanced;

import static com.ss.avframework.live.VeLivePusherDef.VeLiveAudioCaptureType.VeLiveAudioCaptureMicrophone;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherErrorCode.VeLivePusherScreenCaptureInterruptedError;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherErrorCode.VeLivePusherScreenCaptureNotSupportError;
import static com.ss.avframework.live.VeLivePusherDef.VeLivePusherErrorCode.VeLivePusherScreenCaptureStartError;
import static com.ss.avframework.live.VeLivePusherDef.VeLiveVideoCaptureType.VeLiveVideoCaptureScreen;


import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ss.avframework.live.VeLivePusher;
import com.ss.avframework.live.VeLivePusherConfiguration;
import com.ss.avframework.live.VeLivePusherDef;
import com.ss.avframework.live.VeLivePusherObserver;
import com.ttsdk.quickstart.helper.sign.VeLiveURLGenerator;
import com.ttsdk.quickstart.helper.sign.model.VeLivePushURLModel;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLError;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLRootModel;

public class PushScreenActivity extends AppCompatActivity {
    private final String TAG = "PushScreenActivity";
    private static VeLivePusher mLivePusher;
    private EditText mUrlText;
    private TextView mInfoView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_push_screen);
        mInfoView = findViewById(R.id.push_info_text_view);
        mUrlText = findViewById(R.id.url_input_view);
        setupLivePusher();
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
        //  Set the pusher callback
        mLivePusher.setObserver(pusherObserver);
        //  Set periodic information callbacks
        mLivePusher.setStatisticsObserver(statisticsObserver, 3);
        startCapture();
    }

    private void startCapture() {
        //  Start audio capture
        mLivePusher.startAudioCapture(VeLiveAudioCaptureMicrophone);
        //  Start video capture
        mLivePusher.startVideoCapture(VeLiveVideoCaptureScreen);
    }

    public void pushControl(View view) {
        ToggleButton toggleButton = (ToggleButton)view;
        if (mUrlText.getText().toString().isEmpty()) {
            toggleButton.setChecked(false);
            mInfoView.setText(R.string.config_stream_name_tip);
            return;
        }
        if (toggleButton.isChecked()) {
            view.setEnabled(false);
            mInfoView.setText(R.string.Generate_Push_Url_Tip);
            VeLiveURLGenerator.genPushUrl(VeLiveSDKHelper.LIVE_APP_NAME, mUrlText.getText().toString(), new VeLiveURLGenerator.VeLiveURLCallback<VeLivePushURLModel>() {
                @Override
                public void onSuccess(VeLiveURLRootModel<VeLivePushURLModel> model) {
                    view.setEnabled(true);
                    mInfoView.setText("");
                    //  Start pushing the stream, push the stream address support: rtmp protocol, http protocol (RTM)
                    mLivePusher.startPush(model.result.getRtmpPushUrl());
                }

                @Override
                public void onFailed(VeLiveURLError error) {
                    view.setEnabled(true);
                    mInfoView.setText(error.message);
                    toggleButton.setChecked(false);
                }
            });
        } else {
            //  Stop streaming
            mLivePusher.stopPush();
        }
    }

    private final VeLivePusherObserver pusherObserver = new VeLivePusherObserver() {
        @Override
        public void onError(int code, int subCode, String msg) {
            Log.d(TAG, "Error" + code + subCode + msg);
            if (code == VeLivePusherScreenCaptureNotSupportError.value()) {
                Toast.makeText(PushScreenActivity.this, R.string.Screen_Capture_Not_Support_Error, Toast.LENGTH_SHORT).show();
            } else if (code == VeLivePusherScreenCaptureStartError.value()) {
                Toast.makeText(PushScreenActivity.this, R.string.Screen_Capture_Start_Error, Toast.LENGTH_SHORT).show();
            } else if (code == VeLivePusherScreenCaptureInterruptedError.value()) {
                Toast.makeText(PushScreenActivity.this, R.string.Screen_Capture_Interrupted_Error, Toast.LENGTH_SHORT).show();
            }
        }

        @Override
        public void onStatusChange(VeLivePusherDef.VeLivePusherStatus status) {
            Log.d(TAG, "Status" + status);
        }

        @Override
        public void onScreenRecording(boolean open) {
            if (open) {
                //  Start mix system audio
                mLivePusher.startMixSystemAudio();
            } else {
                mLivePusher.stopMixSystemAudio();
            }
        }
    };

    private VeLivePusherDef.VeLivePusherStatisticsObserver statisticsObserver = new VeLivePusherDef.VeLivePusherStatisticsObserver() {
        @Override
        public void onStatistics(VeLivePusherDef.VeLivePusherStatistics statistics) {
            runOnUiThread(() -> mInfoView.setText(VeLiveSDKHelper.getPushInfoString(statistics)));
        }
    };
}