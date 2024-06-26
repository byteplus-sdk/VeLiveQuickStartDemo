/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
package com.ttsdk.quickstart.app;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.multidex.MultiDex;
import android.support.multidex.MultiDexApplication;

import com.bytedance.ttnet.TTNetInit;
import com.ttsdk.quickstart.helper.VeLiveSDKHelper;

public class App extends MultiDexApplication implements Thread.UncaughtExceptionHandler {
    public static App sAppContext;
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        MultiDex.install(this);
        sAppContext = this;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        TTNetInit.tryInitBizTTNet(App.sAppContext, this);
        VeLiveSDKHelper.initTTSDK(App.sAppContext);
    }

    @Override
    public void uncaughtException(@NonNull Thread thread, @NonNull Throwable throwable) {

    }
}
