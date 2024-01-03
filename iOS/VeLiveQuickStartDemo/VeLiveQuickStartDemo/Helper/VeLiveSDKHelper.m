/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveSDKHelper.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//

#import "VeLiveSDKHelper.h"

@implementation VeLiveSDKHelper
+ (void)initTTSDK {
    TTSDKConfiguration *cfg = [TTSDKConfiguration defaultConfigurationWithAppID:TTSDK_APP_ID
                                                                    licenseName:TTSDK_LICENSE_NAME];
    //  Channel configuration, general transmission and distribution type, closed beta, public beta, online, etc
    cfg.channel = @"AppStore";;
    //  App name
    cfg.appName = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleName"];
    // Bundle ID
    cfg.bundleID = NSBundle.mainBundle.bundleIdentifier;
    //  version number
    cfg.appVersion = [NSBundle.mainBundle.infoDictionary objectForKey:@"CFBundleShortVersionString"];
    //  Default Internal Initialization of AppLog
    cfg.shouldInitAppLog = YES;
    //  Configure the service area, the default CN
    cfg.serviceVendor = TTSDKServiceVendorSG;
    //  Configure the unique ID of the current user. Generally, the user ID on the service side is transmitted. If it cannot be obtained at the initial time, it can be configured when the user ID is obtained.
    [TTSDKManager setCurrentUserUniqueID:@"VeLiveQuickStartDemo"];
    //  Whether to report event tracking logs
    [TTSDKManager setShouldReportToAppLog:YES];
    //  Log custom fields for troubleshooting
    [TTSDKManager setAppLogCustomData:@{
        @"CustomKey" : @"CustomValue"
    }];
    //  log configuration
    TTSDKLogConfiguration *logConfig = [[TTSDKLogConfiguration alloc] init];
    //  Whether to output logs to the console
    logConfig.enableConsole = YES;
    //  Whether to write log to file
    logConfig.enableLogFile = YES;
    //  Current device unique ID
    logConfig.deviceID = UIDevice.currentDevice.identifierForVendor.UUIDString;
    //  Maximum file size in MB
    logConfig.maxLogSizeM = 10;
    //  Single file size in MB
    logConfig.singleLogSizeM = 1;
    //  File expiration time, in seconds
    logConfig.logExpireTimeS = 24 * 60 * 60;
    //  log output level
#if DEBUG
    logConfig.logLevel = TTSDKLogLevelDebug;
#else
    logConfig.logLevel = TTSDKLogLevelInfo;
#endif
    //  Configuration log
    cfg.logConfiguration = logConfig;
    //  Start TTSDK
    [TTSDKManager startWithConfiguration:cfg];

}


+ (NSAttributedString *)getPushInfoString:(VeLivePusherStatistics *)statistics {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    paraStyle.lineHeightMultiple = 1.2;
    
    NSAttributedString *(^GetInfoAttributeString)(NSString *localizedKey, id value, NSString *unit) =
    ^NSAttributedString *(NSString *localizedKey, NSString *value, NSString *unit) {
        NSString *infoStr = [NSString stringWithFormat:@"%@:%@%@", NSLocalizedString(localizedKey, nil), value, unit];
        return [[NSAttributedString alloc] initWithString:infoStr attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSParagraphStyleAttributeName : paraStyle,
        }];
    };
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Url", statistics.url, @"\n")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_MaxBitrate", @(statistics.maxVideoBitrate), @" kbps")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_StartBitrate", @(statistics.videoBitrate), @" kbps\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_MinBitrate", @(statistics.minVideoBitrate), @" kbps")];
    NSString *captureResolution = [NSString stringWithFormat:@"%d, %d", (int)statistics.captureWidth, (int)statistics.captureHeight];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_Capture_Resolution", captureResolution, @"\n")];
    
    NSString *pushResolution = [NSString stringWithFormat:@"%d, %d", (int)statistics.encodeWidth, (int)statistics.encodeHeight];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_Push_Resolution", pushResolution, @"")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_Capture_FPS", @(statistics.captureFps), @"\n")];
    
    NSString *ioFps = [NSString stringWithFormat:@"%d/%d", (int)statistics.captureFps, (int)statistics.encodeFps];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_Capture_IO_FPS", ioFps, @"")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Video_Encode_Codec", statistics.codec, @"\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Real_Time_Trans_FPS", @(statistics.transportFps), @"\n")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Real_Time_Encode_Bitrate", @(statistics.encodeVideoBitrate), @" kbps")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Camera_Push_Info_Real_Time_Trans_Bitrate", @(statistics.transportVideoBitrate), @" kbps")];
    return attributedString;
}


+ (NSAttributedString *)getPlaybackInfoString:(VeLivePlayerStatistics *)statistics {
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
    paraStyle.lineHeightMultiple = 1.2;
    
    NSAttributedString *(^GetInfoAttributeString)(NSString *localizedKey, id value, NSString *unit) =
    ^NSAttributedString *(NSString *localizedKey, NSString *value, NSString *unit) {
        NSString *infoStr = [NSString stringWithFormat:@"%@:%@%@", NSLocalizedString(localizedKey, nil), value, unit];
        return [[NSAttributedString alloc] initWithString:infoStr attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName : UIColor.whiteColor,
            NSParagraphStyleAttributeName : paraStyle,
        }];
    };
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Url", statistics.url, @"\n")];
    NSString *videoSize = [NSString stringWithFormat:@"width:%d, height:%d", (int)statistics.width, (int)statistics.height];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Video_Size", videoSize, @"\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Video_FPS", @((int)statistics.fps), @"")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Video_Bitrate", @(statistics.bitrate), @" kbps\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Video_BufferTime", @(statistics.videoBufferMs), @" ms")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Audio_BufferTime", @(statistics.audioBufferMs), @" ms\n")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Stream_Format", [self getPlaybackFormatDes:statistics.format], @"")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Stream_Protocol", [self getPlaybackProtocolDes:statistics.protocol], @"\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Video_Codec", statistics.videoCodec, @"\n")];
    
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Delay_Time", @(statistics.delayMs), @"ms ")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Stall_Time", @(statistics.stallTimeMs), @" ms\n")];
    [attributedString appendAttributedString:GetInfoAttributeString(@"Pull_Stream_Info_Is_HardWareDecode", @(statistics.isHardWareDecode), @"")];
    return attributedString;
}

+ (NSString *)getPlaybackProtocolDes:(VeLivePlayerProtocol)protocol {
   switch (protocol) {
       case VeLivePlayerProtocolTCP: return @"TCP";
       case VeLivePlayerProtocolQUIC: return @"QUIC";
       case VeLivePlayerProtocolTLS: return @"TLS";
   }
   return @"UnKnown";
}
+ (NSString *)getPlaybackFormatDes:(VeLivePlayerFormat)format {
   switch (format) {
       case VeLivePlayerFormatFLV : return @"FLV";
       case VeLivePlayerFormatHLS : return @"HLS";
       case VeLivePlayerFormatRTM : return @"RTM";
   }
   return @"UnKnown";
}
@end
