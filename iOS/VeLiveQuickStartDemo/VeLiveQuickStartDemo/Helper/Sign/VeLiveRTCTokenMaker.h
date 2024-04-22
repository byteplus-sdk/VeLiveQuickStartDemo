/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
// VeLiveRTCTokenMaker.h
// VeLiveSolution
//
//  Created by BytePlus Team on 2024/04/22.
//
//  Copyright (c) 2024/04/22 BytePlus Pte. Ltd.
//
//

#import <Foundation/Foundation.h>
/**
Do not use in production environment, please generate token in the server in the production environment
*/
NS_ASSUME_NONNULL_BEGIN
@interface VeLiveRTCTokenMaker : NSObject
+ (instancetype)shareMaker;
- (void)setupWithAppID:(NSString *)appid appKey:(NSString *)appKey;
- (NSString *)genDefaultTokenWithRoomID:(NSString *)roomId userId:(NSString *)userId;
@end
NS_ASSUME_NONNULL_END
