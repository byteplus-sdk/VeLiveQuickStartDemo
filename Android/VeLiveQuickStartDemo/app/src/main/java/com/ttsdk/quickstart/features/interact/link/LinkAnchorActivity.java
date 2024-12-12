/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.features.interact.link;

import android.support.v7.app.AppCompatActivity;

import android.os.Bundle;
import android.util.Log;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ToggleButton;

import com.ss.bytertc.engine.live.MixedStreamConfig;
import com.ss.bytertc.engine.video.IVideoEffect;
import com.ttsdk.quickstart.R;
import com.ttsdk.quickstart.helper.VeLiveEffectHelper;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;
import com.ttsdk.quickstart.features.interact.manager.VeLiveAnchorManager;
import com.pandora.common.env.Env;
import com.ss.bytertc.engine.RTCVideo;
import com.ss.bytertc.engine.type.MediaStreamType;
import com.ss.bytertc.engine.type.StreamRemoveReason;
import com.ttsdk.quickstart.helper.sign.VeLiveURLGenerator;
import com.ttsdk.quickstart.helper.sign.model.VeLivePushURLModel;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLError;
import com.ttsdk.quickstart.helper.sign.model.VeLiveURLRootModel;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Objects;

public class LinkAnchorActivity extends AppCompatActivity {
    private final String TAG = "LinkAnchorActivity";
    public static final String ROOM_ID = "LinkAnchorActivity_ROOM_ID";
    public static final String USER_ID = "LinkAnchorActivity_USER_ID";
    public static final String TOKEN = "LinkAnchorActivity_TOKEN";

    private LinearLayout mRemoteLinearLayout;
    private EditText mUrlText;
    private TextView mInfoView;
    private String mRoomID;
    private String mUserID;
    private String mToken;
    //  Live streaming host View
    private TextureView mLocalView;
    //  List of users participating in Lianmai
    private ArrayList <String> mUsersInRoom;
    //  Remote user view list during Lianmai process
    private HashMap<String, TextureView> mRemoteUserViews;
    //  Live streaming host + Lianmai manager
    private VeLiveAnchorManager mAnchorManager;
    private final VeLiveAnchorManager.Config mAnchorConfig = new VeLiveAnchorManager.Config();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_link_anchor);
        mRemoteLinearLayout = findViewById(R.id.guest_linear_layout);
        mUrlText = findViewById(R.id.url_input_view);
        mInfoView = findViewById(R.id.push_info_text_view);
        mRoomID = getIntent().getStringExtra(ROOM_ID);
        mUserID = getIntent().getStringExtra(USER_ID);
        mToken = getIntent().getStringExtra(TOKEN);
        mLocalView = findViewById(R.id.render_view);
        setupAnchorManager();
        setupEffectSDK();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        clearInteractUsers();
        VeLiveAnchorManager.destroy();
        mAnchorManager = null;
    }

    private void setupAnchorManager() {
        mUsersInRoom = new ArrayList<>();
        mRemoteUserViews = new HashMap<>();
        mAnchorManager = VeLiveAnchorManager.create(VeLiveSDKHelper.RTC_APPID, mUserID);
        //  Set up push configuration
        mAnchorManager.setConfig(mAnchorConfig);
        //  Configure local preview view
        mAnchorManager.setLocalVideoView(mLocalView);
        //  Enable video capture
        mAnchorManager.startVideoCapture();
        //  Turn on audio capture
        mAnchorManager.startAudioCapture();
    }

    private void startPush(String url) {
        if (url == null || url.isEmpty()) {
            Log.e(TAG, "Please config push url");
            return;
        }
        //  Start pushing
        mAnchorManager.startPush(url);
    }
    private void stopPush() {
        mAnchorManager.stopPush();
    }

    private void clearInteractUsers() {
        //  Start Lianmai
        //  Clear historical users, business logic processing
        mUsersInRoom.clear();
        Object[] remoteViews = mRemoteUserViews.values().toArray();
        for (Object remoteView : remoteViews) {
            if (remoteView instanceof View) {
                mRemoteLinearLayout.removeView((View)remoteView);
            }
        }
        mRemoteUserViews.clear();
    }

    private void startInteractive() {
        clearInteractUsers();
        mAnchorManager.startInteract(mRoomID, mToken, anchorListener);
    }

    private void stopInteractive() {
        clearInteractUsers();
        mAnchorManager.stopInteract();
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
                    startPush(model.result.getRtmpPushUrl());
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
            stopPush();
        }
    }

    public void interactControl(View view) {
        ToggleButton toggleButton = (ToggleButton) view;
        if (toggleButton.isChecked()) {
            startInteractive();
        } else {
            stopInteractive();
        }
    }

    public void seiControl(View view) {
        mAnchorManager.sendSeiMessage("anchor_test_sei", 20);
    }

    private void setupEffectSDK() {

        //  Effects Authentication License path, please find the correct path according to the project configuration
        String licPath = VeLiveEffectHelper.getLicensePath("xxx.licbag");
        //  Effect model effect package path
        String algoModePath = VeLiveEffectHelper.getModelPath();
        if (!VeLiveSDKHelper.isFileExists(licPath) || !VeLiveSDKHelper.isFileExists(algoModePath)) {
            return;
        }
        IVideoEffect effect = mAnchorManager.getRTCVideo().getVideoEffectInterface();
        //  Check the License
        //  Set up special effects algorithm package
        effect.initCVResource(licPath, algoModePath);

        if (effect.enableVideoEffect() != 0) {
            Log.e(TAG, "enable effect error");
        }
    }

    public void beautyControl(View view) {
        //  According to the effect package, find the correct resource path, generally to the reshape_lite, beauty_IOS_lite directory
        String beautyPath = VeLiveEffectHelper.getBeautyPathByName("xxx");
        if (!VeLiveSDKHelper.isFileExists(beautyPath)) {
            return;
        }
        IVideoEffect effect = mAnchorManager.getRTCVideo().getVideoEffectInterface();
        //  Set up beauty effect package
        effect.setEffectNodes(Collections.singletonList(beautyPath));
        //  Set the beauty effect intensity, NodeKey can be obtained in the config_file under the effect package, if there is no config_file, please contact the business consultation
        effect.updateEffectNode(beautyPath, "whiten", 0.5F);
    }

    public void filterControl(View view) {
        //  Filter effect package, find the correct resource path, generally to the Filter_01_xx directory
        String filterPath = VeLiveEffectHelper.getFilterPathByName("xxx");;
        if (!VeLiveSDKHelper.isFileExists(filterPath)) {
            return;
        }
        IVideoEffect effect = mAnchorManager.getRTCVideo().getVideoEffectInterface();
        //  Set the filter effect package path
        effect.setColorFilter(filterPath);
        //  Set filter effect intensity
        effect.setColorFilterIntensity(0.5F);
    }

    public void stickerControl(View view) {
        //  Sticker effect package, find the correct resource path, generally to the stickers_xxx directory
        String stickerPath = VeLiveEffectHelper.getStickerPathByName("xxx");
        if (!VeLiveSDKHelper.isFileExists(stickerPath)) {
            return;
        }
        IVideoEffect effect = mAnchorManager.getRTCVideo().getVideoEffectInterface();
        //  Set the sticker effect package path
        effect.appendEffectNodes(Collections.singletonList(stickerPath));
    }

    private MixedStreamConfig.MixedStreamLayoutConfig getTranscodingLayout() {
        MixedStreamConfig.MixedStreamLayoutConfig layout = new MixedStreamConfig.MixedStreamLayoutConfig();
        //  Set background color
        layout.setBackgroundColor("#000000");
        int guestIndex = 0;
        float density = getResources().getDisplayMetrics().density;
        float viewWidth = getResources().getDisplayMetrics().widthPixels / density;
        float viewHeight = getResources().getDisplayMetrics().heightPixels / density;

        double guestX = (viewWidth - 130.0) / viewWidth;
        double guestStartY = (viewHeight - 42.0) / viewHeight;
        MixedStreamConfig.MixedStreamLayoutRegionConfig[] regions = new MixedStreamConfig.MixedStreamLayoutRegionConfig[mUsersInRoom.size()];
        int pos = 0;
        for (String uid : mUsersInRoom) {
            MixedStreamConfig.MixedStreamLayoutRegionConfig region = new MixedStreamConfig.MixedStreamLayoutRegionConfig();
            region.setUserID(uid);
            region.setRoomID(mRoomID);
            region.setRenderMode(MixedStreamConfig.MixedStreamRenderMode.MIXED_STREAM_RENDER_MODE_HIDDEN);
            region.setIsLocalUser(Objects.equals(uid, mUserID));
            if (region.getIsLocalUser()) { // Current live streaming host location, for reference only
                region.setLocationX(0);
                region.setLocationY(0);
                region.setWidth(mAnchorConfig.mVideoEncoderWidth);
                region.setHeight(mAnchorConfig.mVideoEncoderHeight);
                region.setZOrder(0);
                region.setAlpha(1);
            } else { //  Remote user location, for reference only
                //  130 is the width and height of the small windows, 8 is the spacing of the small windows
                region.setLocationX((int)(guestX * mAnchorConfig.mVideoEncoderWidth));
                double yScale = guestStartY - (130.0 * (guestIndex + 1) + guestIndex * 8) / viewHeight;
                region.setLocationY((int)(yScale * mAnchorConfig.mVideoEncoderHeight));
                region.setWidth((int)(130.0 / viewWidth * mAnchorConfig.mVideoEncoderWidth));
                region.setHeight((int)(130.0 / viewHeight * mAnchorConfig.mVideoEncoderHeight));
                region.setZOrder(1);
                region.setAlpha(1);
                guestIndex ++;
            }
            regions[pos++] = region;
        }
        layout.setRegions(regions);
        return layout;
    }

    private TextureView getTextureView(String uid) {
        TextureView textureView = mRemoteUserViews.get(uid);
        if (textureView == null) {
            textureView = new TextureView(this);
            int width = (int)(130 * getResources().getDisplayMetrics().density);
            LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, width);
            layoutParams.weight = 1;
            layoutParams.topMargin = 8;
            textureView.setLayoutParams(layoutParams);
            mRemoteUserViews.put(uid, textureView);
        }
        return textureView;
    }

    private VeLiveAnchorManager.IListener anchorListener = new VeLiveAnchorManager.IListener() {
        @Override
        public void onUserJoined(String uid) {
            Log.d(TAG, "onUserJoined, uid: " + uid);
            mUsersInRoom.add(uid);
            mAnchorManager.updatePushMixedStreamToCDN(getTranscodingLayout());
        }

        @Override
        public void onUserLeave(String uid) {
            Log.d(TAG, "onUserLeave, uid: " + uid);
            mUsersInRoom.remove(uid);
            mAnchorManager.updatePushMixedStreamToCDN(getTranscodingLayout());
        }

        @Override
        public void onJoinRoom(String uid, int state) {
            Log.d(TAG, "onJoinRoom, uid: " + uid + ", state: " + state);
            if (state != 0) { //  Failed to join room
                runOnUiThread(() -> stopInteractive());
                return;
            }
            mUsersInRoom.add(uid);
            mAnchorManager.updatePushMixedStreamToCDN(getTranscodingLayout());
        }

        @Override
        public void onUserPublishStream(String uid, MediaStreamType type) {
            Log.d(TAG, "onUserPublishStream, uid: " + uid + ", type: " + type);
            if (type == MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO) {
                return;
            }
            try {
                TextureView textureView = getTextureView(uid);
                runOnUiThread(() -> {
                    mRemoteLinearLayout.addView(textureView, 0);
                });
                //  Configure remote view
                mAnchorManager.setRemoteVideoView(uid, textureView);
                //  Update Mixed Stream Layout
                mAnchorManager.updatePushMixedStreamToCDN(getTranscodingLayout());
            } catch (Exception e) {
                Log.e(TAG, e.toString());
            }
        }

        @Override
        public void onUserUnPublishStream(String uid, MediaStreamType type, StreamRemoveReason reason) {
            Log.d(TAG, "onUserUnPublishStream, uid: " + uid + ", type: " + type + ", reason: " + reason);
            if (type == MediaStreamType.RTC_MEDIA_STREAM_TYPE_AUDIO) {
                return;
            }
            mUsersInRoom.remove(uid);
            runOnUiThread(() -> {
                TextureView textureView = mRemoteUserViews.get(uid);
                if (textureView != null) {
                    mRemoteLinearLayout.removeView(textureView);
                    mRemoteUserViews.remove(uid);
                }
            });
            //  Remove remote view
            mAnchorManager.setRemoteVideoView(uid, null);
            //  Update Mixed Stream Layout
            mAnchorManager.updatePushMixedStreamToCDN(getTranscodingLayout());
        }
    };
}