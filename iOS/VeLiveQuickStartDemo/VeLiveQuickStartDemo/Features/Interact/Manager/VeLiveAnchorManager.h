/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveAnchorManager.h
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/2/22.
//

#import <UIKit/UIKit.h>
#import "VeLiveSDKHelper.h"
#import "VeLiveConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class VeLiveAnchorManager;
@protocol VeLiveAnchorDelegate <NSObject>
//  User joins room
- (void)manager:(VeLiveAnchorManager *)manager onUserJoined:(NSString *)uid;
//  User leaves room event callback
- (void)manager:(VeLiveAnchorManager *)manager onUserLeave:(NSString *)uid;
//  I join the room callback
- (void)manager:(VeLiveAnchorManager *)manager onJoinRoom:(NSString *)uid state:(NSInteger)state;
//  User publishes video stream callbacks for updating confluence layouts
- (void)manager:(VeLiveAnchorManager *)manager onUserPublishStream:(NSString *)uid type:(ByteRTCMediaStreamType)streamType;
//  User unpublishes video stream callback for updating confluence layout
- (void)manager:(VeLiveAnchorManager *)manager onUserUnPublishStream:(NSString *)uid type:(ByteRTCMediaStreamType)streamType reason:(ByteRTCStreamRemoveReason)reason;
@end

@interface VeLiveAnchorManager : NSObject
//  Thruster engine
@property (nonatomic, strong, readonly) VeLivePusher *livePusher;
//  Live streaming host preview view
@property (nonatomic, strong) UIView *localVideoView;
//  Live + RTC streaming configuration
@property (nonatomic, strong, nullable) VeLiveConfig *config;
//  RTC video management
@property (nonatomic, strong, readonly, nullable) ByteRTCVideo *rtcVideo;
//  RTC Room Management
@property (nonatomic, strong, readonly, nullable) ByteRTCRoom *rtcRoom;
//  Appid passed in at creation
@property (nonatomic, copy, readonly, nullable) NSString *appId;
//  When created, the userId passed in
@property (nonatomic, copy, readonly, nullable) NSString *userId;
//  Joined room ID
@property (nonatomic, copy, readonly, nullable) NSString *roomId;
//  Token to join the room
@property (nonatomic, copy, readonly, nullable) NSString *token;
//  Is it even in the wheat?
@property (nonatomic, assign, getter=isInteractive, readonly) BOOL interactive;
//  Agent
@property(nonatomic, weak) id <VeLiveAnchorDelegate> delegate;

//  Initialization
- (instancetype)initWithAppId:(NSString *)appId userId:(NSString *)userId NS_DESIGNATED_INITIALIZER;

//  Configure Remote User View
- (void)setRemoteVideoView:(nullable UIView *)view forUid:(NSString *)uid;

//  Enable video capture
- (void)startVideoCapture;

//  Stop video capture
- (void)stopVideoCapture;

//  Turn on audio capture
- (void)startAudioCapture;

//  Stop audio capture
- (void)stopAudioCapture;

//  Start Lianmai
- (void)startInteract:(NSString *)roomId token:(NSString *)token delegate:(id <VeLiveAnchorDelegate>)delegate;

//  Stop Lianmai
- (void)stopInteract;

//  Send SEI message
// - Parameters:
//    - message: sei message length, up to 2kb
//   - repeat: [0, 30]
- (void)sendSeiMessage:(NSString *)message repeat:(int)repeat;

//  Destroy the engine
- (void)destory;

//  Start pushing
- (void)startPush:(NSString *)url;

//  Stop streaming
- (void)stopPush;

//  Update Confluence Layout
- (void)updateLiveTranscodingLayout:(ByteRTCMixedStreamLayoutConfig *)layout;

//  Start retweeting across rooms
- (void)startForwardStream:(NSArray <ByteRTCForwardStreamConfiguration *> *)forwardStreamInfos;

//  Stop retweeting across rooms
- (void)stopForwardStream;
@end

NS_ASSUME_NONNULL_END
