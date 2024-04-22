/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
// VeLiveURLRequestHelper.h
// VeLiveLiveDemo
// 
//  Created by BytePlus Team on 2024/04/22.
//
//  Copyright (c) 2024/04/22 BytePlus Pte. Ltd.
//
//

#import <Foundation/Foundation.h>
#import "VeLiveURLModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VeLiveURLSceneType) {
    VeLiveURLSceneTypePull,
    VeLiveURLSceneTypePush
};
/**
Do not use in production environment, please generate push and pull stream addresses in the server in the production environment
*/
@interface VeLiveURLGenerator : NSObject

/**
config url generator
https://www.volcengine.com/docs/6291/65568 获取
- Parameters:
  - accessKey: ak
  - secretKey: sk
*/
+ (void)setupWithAccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey;

/**
config domain space, push and pull stream domain
https://console.volcengine.com/live/main/domain/list
- Parameters:
  - vHost: domain space
  - pushDomain: push domain
  - pullDomain: pull domain
*/
+ (void)setupVhost:(NSString *)vHost pushDomain:(NSString *)pushDomain pullDomain:(NSString *)pullDomain;

/**
generate push stream address
- Parameters:
  - app: app name
  - streamName: stream name
  - sceneType: push / pull
  - completion: callback
*/
+ (void)genPushURLForApp:(NSString *)app streamName:(NSString *)streamName completion:(void (^)(VeLiveURLRootModel <VeLivePushURLModel *>*_Nullable model, NSError *_Nullable error))completion;

/**
generate pull stream address
- Parameters:
  - app: app name
  - streamName: stream name
  - completion: callback
*/
+ (void)genPullURLForApp:(NSString *)app streamName:(NSString *)streamName completion:(void (^)(VeLiveURLRootModel <VeLivePullURLModel *>*_Nullable model, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
