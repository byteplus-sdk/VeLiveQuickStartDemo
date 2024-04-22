/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveSDKHelper.h
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//

#import <UIKit/UIKit.h>
/*
 This file stores the basic configuration information of the SDK, regardless of the information. It can be modified on the interface when entering the corresponding page.
 This file stores the basic configuration information of the SDK, including SDK AppID, License file name, up & down streaming address, and Lianmai interactive room ID., live streaming host/viewer UID and temporary Token
 SDK configuration information application: https://console.volcengine.com/live/main/sdk
  up & down streaming address generation reference document: https://console.volcengine.com/live/main/locationGenerate
 Interactive live broadcast related reference document: https://console.volcengine.com/rtc/listRTC
 */
// AppID
#define TTSDK_APP_ID @""
/*
 License name, the current Demo file is stored in the same directory as this file. If you do SDK quick verification, you can directly replace the content of the ttsdk.lic file
 */
#define TTSDK_LICENSE_NAME @"ttsdk.lic"

/*
 *  Access Key https://console.byteplus.com/iam/keymanage/
 */
#define ACCESS_KEY_ID @""
#define SECRET_ACCESS_KEY @""

/*
 * vhost for live push and pull streaming
 * https://console.byteplus.com/iam/resourcemanage/project/default/
 */
#define LIVE_VHOST @""

/*
 * Used when generating the live push-pull stream address
 * eg.: https://pull.example.com/live/abc.flv
 */
#define LIVE_APP_NAME @"live"


/*
 * domain for live push https://console.byteplus.com/live/main/domain/list
 */
#define LIVE_PUSH_DOMAIN @""

/*
 * domain for live pull https://console.byteplus.com/live/main/domain/list
 */
#define LIVE_PULL_DOMAIN @""

/*
 Interactive Live AppID
 */
#define RTC_APPID @""

/*
 Interactive Live AppKey
 */
#define RTC_APPKEY @""

#define EFFECT_LICENSE_NAME @""

#import <TTSDKFramework/TTSDKFramework.h>
#import <BytePlusRTC/BytePlusRTC.h>

#import "VeLiveDeviceCapture.h"
#import "VeLiveURLGenerator.h"
#import "VeLiveRTCTokenMaker.h"

NS_ASSUME_NONNULL_BEGIN
@class VeLivePlayerStatistics;
@class VeLivePusherStatistics;
@interface VeLiveSDKHelper : NSObject
/*
 Initialize SDK related configuration
 */
+ (void)initTTSDK;

/*
 Get the push stream information string, which is convenient for multiple uses
 */
+ (NSAttributedString *)getPushInfoString:(VeLivePusherStatistics *)statistics;

/*
 Get the pull stream information string, which is convenient for multiple uses
 */
+ (NSAttributedString *)getPlaybackInfoString:(VeLivePlayerStatistics *)statistics;
@end

NS_ASSUME_NONNULL_END
