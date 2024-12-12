/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
// VeLiveFileConfig.h
//
//  Created by BytePlus Team on 2024/11/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface VeLiveFileConfig : NSObject
///  Read data interval
@property (nonatomic, assign, readonly) NSTimeInterval interval;
///  data size per read
@property (nonatomic, assign, readonly) int packetSize;
///  file path
@property (nonatomic, copy) NSString *path;
///  file name
@property (nonatomic, copy) NSString *name;

///  Is it valid?
- (BOOL)isValid;

@end

///  Video file type
typedef NS_ENUM(NSInteger, VELVideoFileType) {
    VELVideoFileType_UnKnown,
    VELVideoFileType_BGRA,
    VELVideoFileType_NV12,
    VELVideoFileType_NV21,
    VELVideoFileType_YUV
};

typedef NS_ENUM(NSInteger, VELVideoFileConvertType) {
    VELVideoFileConvertTypeUnKnown,
    VELVideoFileConvertTypeTextureID = 1,
    VELVideoFileConvertTypeEncodeData,
    VELVideoFileConvertTypePixelBuffer,
    VELVideoFileConvertTypeSampleBuffer,
};
@interface VELVideoFileConfig : VeLiveFileConfig
///  Acquisition frame rate, default 25
@property (nonatomic, assign) int fps;
///  Video width, default 640
@property (nonatomic, assign) int width;
///  Video height, default 360
@property (nonatomic, assign) int height;
///  File type, default VELVideoFileType_UnKnown
@property (nonatomic, assign) VELVideoFileType fileType;
///  file type description
@property (nonatomic, copy, readonly) NSString *fileTypeDes;
///  Type to be converted
@property (nonatomic, assign) VELVideoFileConvertType convertType;
@end

///  Audio file type
typedef NS_ENUM(NSInteger, VELAudioFileType) {
    VELAudioFileType_UnKnown,
    VELAudioFileType_PCM,
};

@interface VELAudioFileConfig : VeLiveFileConfig
///  How many reads per second, default 100
@property (nonatomic, assign) int readCountPerSecond;
///  Sample rate, default: 44100
@property (nonatomic, assign) int sampleRate;
///  Bit depth, default: 16
@property (nonatomic, assign) int bitDepth;
///  Number of channels, default: 2
@property (nonatomic, assign) int channels;
///  File type, currently only pcm data is supported, the default VELAudioFileType_UnKnown
@property (nonatomic, assign) VELAudioFileType fileType;

@property (nonatomic, assign) BOOL playable;
@end

UIKIT_STATIC_INLINE void vel_sync_main_queue(dispatch_block_t block) {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

//  error
#define VEL_ERROR(c, des) [NSError errorWithDomain:NSURLErrorDomain code:c userInfo:@{NSLocalizedDescriptionKey : des?:@""}]
//  Current CMTime, nanoseconds
#define VEL_CURRENT_CMTIME CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000)
//  Is it an empty object?
#define VEL_IS_NULL_OBJ(obj) (obj == nil || ((id)obj == NSNull.null) || [obj isKindOfClass:NSNull.class])
//  Is it an empty string?
#define VEL_IS_EMPTY_STRING(s) (VEL_IS_NULL_OBJ(s) || s.length == 0)
#define VEL_IS_NOT_EMPTY_STRING(s) !VEL_IS_EMPTY_STRING(s)

NS_ASSUME_NONNULL_END
