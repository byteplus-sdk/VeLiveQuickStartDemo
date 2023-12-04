/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveLinkAnchorViewController.h
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/12/04.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VeLiveLinkAnchorViewController : UIViewController
//  Current room ID
// current room ID
@property (nonatomic, copy) NSString *roomID;
//  Current live streaming host user ID
// current anchor user ID
@property (nonatomic, copy) NSString *userID;
//  The token of the current live streaming host in the current room
// The token of the current anchor in the current room
@property (nonatomic, copy) NSString *token;
@end

NS_ASSUME_NONNULL_END
