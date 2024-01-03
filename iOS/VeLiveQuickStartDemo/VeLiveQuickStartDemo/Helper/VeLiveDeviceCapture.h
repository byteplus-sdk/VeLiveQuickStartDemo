/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveDeviceCapture.h
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//
/*
 This class provides basic camera capture capabilities for use in custom capture.
 Please implement relevant capture by yourself in your own business. It is not recommended to use this file directly for audio & video capture.
 */
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VeLiveDeviceCapture;
@protocol VeLiveDeviceCaptureDelegate <NSObject>
- (void)capture:(VeLiveDeviceCapture *)capture didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)capture:(VeLiveDeviceCapture *)capture didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface VeLiveDeviceCapture : NSObject

@property (weak, nonatomic) id <VeLiveDeviceCaptureDelegate> delegate;

- (void)startCapture;

- (void)stopCapture;

+ (void)requestCameraAndMicroAuthorization:(void (^)(BOOL cameraGranted, BOOL microGranted))handler;

+ (void)requestCameraAuthorization:(void (^)(BOOL granted))handler;

+ (void)requestMicrophoneAuthorization:(void (^)(BOOL granted))handler;
@end

NS_ASSUME_NONNULL_END
