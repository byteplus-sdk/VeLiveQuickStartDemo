/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VELiveConfig.h
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/12/04.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VeLiveConfig : NSObject
//  Acquisition width
@property (nonatomic, assign) int captureWidth;
//  Acquisition height
@property (nonatomic, assign) int captureHeight;
//  Acquisition frame rate
@property (nonatomic, assign) int captureFps;
//  Audio sample rate
@property (nonatomic, assign) int audioCaptureSampleRate;
//  Number of audio channels
@property (nonatomic, assign) int audioCaptureChannel;
//  video encoding width
@property (nonatomic, assign) int videoEncoderWith;
//  Video coding high
@property (nonatomic, assign) int videoEncoderHeight;
//  Video coding frame rate
@property (nonatomic, assign) int videoEncoderFps;
//  Video Coding Bit Rate
@property (nonatomic, assign) int videoEncoderKBitrate;
//  Whether to turn on hardware encoding
@property (nonatomic, assign) BOOL videoHardwareEncoder;
//  Audio Coding Sample Rate
@property (nonatomic, assign) int audioEncoderSampleRate;
//  Number of audio coding channels
@property (nonatomic, assign) int audioEncoderChannel;
//  Audio Coding Bit Rate
@property (nonatomic, assign) int audioEncoderKBitrate;
@end
NS_ASSUME_NONNULL_END
