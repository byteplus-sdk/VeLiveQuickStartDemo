/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  VeLiveFileReader.h
//
//  Created by BytePlus Team on 2024/11/21.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "VeLiveFileConfig.h"
NS_ASSUME_NONNULL_BEGIN
///  data callback
typedef void (^VELFileDataBlock)(NSData *_Nullable data, CMTime pts);
///  The file will be lost after reading.
typedef void (^FLEFileReadCompletionBlock)(NSError *_Nullable error, BOOL isEnd);
@interface VeLiveFileReader : NSObject
///  Whether to read the file repeatedly,
@property (atomic, assign) BOOL repeat;

///  Create a raw data file reader
///  - Parameter config: Configuration
+ (instancetype)readerWithConfig:(__kindof VeLiveFileConfig *)config;

///  Start reading the file
- (void)startWithDataCallBack:(VELFileDataBlock)dataCallBack completion:(FLEFileReadCompletionBlock)completion;

///  Stop reading file
- (void)stop;

///  pause
- (void)pause;

///  recover
- (void)resume;
@end

NS_ASSUME_NONNULL_END
