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
 RTMP, RTM, Quic push stream address
  generation method: generate https://console.volcengine.com/live/main/locationGenerate through the console
 */
#define LIVE_PUSH_URL @""
#define LIVE_RTM_PUSH_URL @""

/*
 RTM, rtmp, flv, m3u8 pull stream address
  generation method: generate https://console.volcengine.com/live/main/locationGenerate through the console
 */
#define LIVE_PULL_URL @""
#define LIVE_RTM_PULL_URL @""


/*
 Interactive Live AppID
 */
#define RTC_APPID @""

/*
 Interactive live streaming host room ID
 */
#define RTC_ROOM_ID @""

/*
 Interactive live streaming host user ID
 */
#define RTC_USER_ID @""

/*
 Interactive live streaming host user Token
 Generation method: use live streaming host room ID and live streaming host user ID to generate
 https://console.volcengine.com/rtc/listRTC in the RTC console
 */
#define RTC_USER_TOKEN @""

/*
 When live streaming host and live streaming host PK, the room ID of the other live streaming host
 */
#define RTC_OTHER_ROOM_ID @""

/*
 When live streaming host and live streaming host PK, the current live streaming host joins the token
  generation method in the other party's live streaming host room: use the user ID of the current live streaming host and the room ID of the other party's live streaming host to generate it in the console
 */
#define RTC_OTHER_ROOM_TOKEN @""

#import <TTSDKFramework/TTSDKFramework.h>
#import <BytePlusRTC/BytePlusRTC.h>

#import "VeLiveDeviceCapture.h"

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
