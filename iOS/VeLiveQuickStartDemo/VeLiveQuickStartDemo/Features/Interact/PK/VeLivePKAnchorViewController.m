/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePKAnchorViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//

#import "VeLivePKAnchorViewController.h"
#import "VeLiveAnchorManager.h"
@interface VeLivePKAnchorViewController () <VeLiveAnchorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *seiControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *pkControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerControlBtn;
//  List of users participating in Lianmai
@property (nonatomic, strong) NSMutableArray <NSString *> *usersInRoom;
//  Current live streaming host view
@property (nonatomic, strong) IBOutlet UIView *localView;
//  Live streaming host view
@property (nonatomic, strong) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIStackView *pkStackView;
//  Live streaming host + Lianmai manager
@property (nonatomic, strong) VeLiveAnchorManager *liveAnchorManager;

@end

@implementation VeLivePKAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupAnchorManager];
    [self setupEffectSDK];
}

- (void)dealloc {
    //  Destroy Lianmai Manager
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    if (self.liveAnchorManager != nil) {
        [self.liveAnchorManager destory];
        self.liveAnchorManager = nil;
    }
}

- (void)setupAnchorManager {
    self.usersInRoom = [NSMutableArray arrayWithCapacity:2];
    self.liveAnchorManager = [[VeLiveAnchorManager alloc] initWithAppId:RTC_APPID
                                                                 userId:self.userID];
    //  Configure local preview view
    [self.liveAnchorManager setLocalVideoView:self.previewView];
    //  Enable video capture
    [self.liveAnchorManager startVideoCapture];
    //  Turn on audio capture
    [self.liveAnchorManager startAudioCapture];
    //  Start pushing
    [self startPush];
}

- (void)startPush {
    if (self.urlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please config push url");
        return;
    }
    //  Start pushing
    [self.liveAnchorManager startPush:self.urlTextField.text];
    [self.view sendSubviewToBack:self.previewView];
}

- (void)stopPush {
    [self.liveAnchorManager stopPush];
}

//  Start retweeting across rooms
- (void)startForward {
    //  Retweet across rooms
    ForwardStreamConfiguration *cfg = [[ForwardStreamConfiguration alloc] init];
    cfg.roomId = self.otherRoomID;
    cfg.token = self.otherRoomToken;
    [self.liveAnchorManager startForwardStream:@[cfg]];
}

//  Stop retweeting across rooms
- (void)stopForward {
    [self.liveAnchorManager stopForwardStream];
}

- (void)clearInteractUsers {
    //  Start Lianmai
    //  Clear historical users, business logic processing
    [self.usersInRoom removeAllObjects];
}

- (void)startPK {
    [self clearInteractUsers];
    self.previewView.hidden = YES;
    self.pkStackView.hidden = NO;
    [self.liveAnchorManager setLocalVideoView:self.localView];
    //  Join the room, and after joining the room callback, start retweeting across rooms
    [self.liveAnchorManager startInteract:self.roomID
                                    token:self.token
                                 delegate:self];
}

- (void)stopPK {
    self.previewView.hidden = NO;
    self.pkStackView.hidden = YES;
    [self.liveAnchorManager setLocalVideoView:self.previewView];
    [self.view sendSubviewToBack:self.previewView];
    [self clearInteractUsers];
    //  Stop retweeting across rooms
    [self stopForward];
    //  Leave the room
    [self.liveAnchorManager stopInteract];
}

- (IBAction)pushControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config Url");
        return;
    }
    if (!sender.isSelected) {
        [self startPush];
    } else {
        [self stopPush];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)pkControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config Url");
        return;
    }
    if (!sender.isSelected) {
        [self startPK];
    } else {
        [self stopPK];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)seiControl:(UIButton *)sender {
    [self.liveAnchorManager sendSeiMessage:@"anchor_test_sei" repeat:20];
}

- (void)setupEffectSDK {
    //  Note: This method only takes effect when the SDK of intelligent beautification special effects has been integrated in the project
    ByteRTCVideo *rtcVideo = self.liveAnchorManager.rtcVideo;
    
    //  Effects Authentication License path, please find the correct path according to the project configuration
    NSString *licensePath = [NSBundle.mainBundle pathForResource:@"LicenseBag.bundle/xxx.licbag" ofType:nil];
    
    //  Effect algorithm effect package path
    NSString *algoModelPath = [NSBundle.mainBundle pathForResource:@"ModelResource.bundle" ofType:nil];
    
    if (![NSFileManager.defaultManager fileExistsAtPath:licensePath]) {
        return;
    }
    [rtcVideo.getVideoEffectInterface initCVResource:licensePath withAlgoModelDir:algoModelPath];
    
    //  Turn on beauty effects
    if ([rtcVideo.getVideoEffectInterface enableVideoEffect] != 0) {
        NSLog(@"VeLiveQuickStartDemo: license unavailabel, please check");
    }
}

- (IBAction)beautyControl:(UIButton *)sender {
    //  According to the effect package, find the correct resource path, generally to the reshape_lite, beauty_IOS_lite directory
    NSString *beautyPath = [NSBundle.mainBundle pathForResource:@"ComposeMakeup.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:beautyPath]) {
        return;
    }
    //  Set up beauty effect package
    [self.liveAnchorManager.rtcVideo.getVideoEffectInterface setEffectNodes:@[beautyPath]];
    
    //  Set the beauty effect intensity, NodeKey can be obtained in the config_file under the effect package, if there is no config_file, please contact the business consultation
    [self.liveAnchorManager.rtcVideo.getVideoEffectInterface updateEffectNode:beautyPath key:@"whiten" value:0.5];
}

- (IBAction)filterControl:(UIButton *)sender {
    //  Filter effect package, find the correct resource path, generally to the Filter_01_xx directory
    NSString *filterPath = [NSBundle.mainBundle pathForResource:@"FilterResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:filterPath]) {
        return;
    }
    [self.liveAnchorManager.rtcVideo.getVideoEffectInterface setColorFilter:filterPath];
    [self.liveAnchorManager.rtcVideo.getVideoEffectInterface setColorFilterIntensity:0.5];
}

- (IBAction)stickerControl:(UIButton *)sender {
    //  Sticker effect package, find the correct resource path, generally to the stickers_xxx directory
    NSString *stickerPath = [NSBundle.mainBundle pathForResource:@"StickerResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:stickerPath]) {
        return;
    }
    [self.liveAnchorManager.rtcVideo.getVideoEffectInterface appendEffectNodes:@[stickerPath]];
}


// MARK: - VeLiveAnchorDelegate
- (void)manager:(VeLiveAnchorManager *)manager onJoinRoom:(NSString *)uid state:(NSInteger)state {
    [self.usersInRoom addObject:[uid copy]];
    
    //  Update layout parameters
    [manager updateLiveTranscodingLayout:[self rtcLayout]];
    
    //  Current live streaming host, start retweeting across rooms
    if ([uid isEqualToString:self.userID]) {
        [self startForward];
    }
}

- (void)manager:(VeLiveAnchorManager *)manager onUserJoined:(NSString *)uid {
    [self.usersInRoom addObject:uid.copy];
}

- (void)manager:(VeLiveAnchorManager *)manager onUserLeave:(NSString *)uid {
    //  Update Lianmai user list
    [self.usersInRoom removeObject:uid];
    //  Update Mixed Stream Layout
    [manager updateLiveTranscodingLayout:[self rtcLayout]];
}

- (void)manager:(VeLiveAnchorManager *)manager onUserPublishStream:(nonnull NSString *)uid type:(ByteRTCMediaStreamType)streamType {
    if (streamType == ByteRTCMediaStreamTypeAudio) {
        return;
    }
    //  Setting up remote user views
    [manager setRemoteVideoView:self.remoteView forUid:uid];
    
    //  Update layout parameters
    [manager updateLiveTranscodingLayout:[self rtcLayout]];
}

- (void)manager:(VeLiveAnchorManager *)manager onUserUnPublishStream:(nonnull NSString *)uid type:(ByteRTCMediaStreamType)streamType reason:(ByteRTCStreamRemoveReason)reason {
    if (streamType == ByteRTCMediaStreamTypeAudio) {
        return;
    }
    [self.usersInRoom removeObject:uid];
    //  Remove remote view
    [manager setRemoteVideoView:nil forUid:uid];
    //  Update Mixed Stream Layout
    [manager updateLiveTranscodingLayout:[self rtcLayout]];
}

- (ByteRTCMixedStreamLayoutConfig *)rtcLayout {
    //  Initialize layout
    ByteRTCMixedStreamLayoutConfig * layout = [[ByteRTCMixedStreamLayoutConfig alloc]init];
    
    //  Set background color
    layout.backgroundColor = @"#000000"; // For reference only
 
    NSMutableArray *regions = [[NSMutableArray alloc]initWithCapacity:6];
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat pkViewWidth = (viewWidth - 8) * 0.5 / viewWidth;;
    CGFloat pkViewHeight =  260 / viewHeight;
    CGFloat pkViewY =  209 / viewHeight;
    
    [self.usersInRoom enumerateObjectsUsingBlock:^(NSString * _Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ByteRTCMixedStreamLayoutRegionConfig *region = [[ByteRTCMixedStreamLayoutRegionConfig alloc]init];
        region.userID          = uid;
        region.roomID       = self.roomID;
        region.isLocalUser    = [uid isEqualToString:self.userID]; //  Determine whether it is the current live streaming host
        region.renderMode   = ByteRTCMixedStreamRenderModeHidden;
        
        if (region.isLocalUser) { // Current live streaming host location, for reference only
            region.locationX        = 0.0;
            region.locationY        = pkViewY;
            region.widthProportion    = pkViewWidth;
            region.heightProportion   = pkViewHeight;
            region.zOrder   = 0;
            region.alpha    = 1.0;
        } else { //  Remote user location, for reference only
            region.locationX        = (viewWidth * 0.5 + 8) / viewWidth;
            region.locationY        = pkViewY;
            region.widthProportion    = pkViewWidth;
            region.heightProportion   =  pkViewHeight;
            region.zOrder   = 1;
            region.alpha    = 1;
        }
        [regions addObject:region];
    }];
    layout.regions = regions;
    return layout;
}

- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Interact_Link_Anchor_Title", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlTextField.text = LIVE_PUSH_URL;
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
    
    [self.pkControlBtn setTitle:NSLocalizedString(@"Interact_Start_PK", nil) forState:(UIControlStateNormal)];
    [self.pkControlBtn setTitle:NSLocalizedString(@"Interact_Stop_PK", nil) forState:(UIControlStateSelected)];
    
    [self.seiControlBtn setTitle:NSLocalizedString(@"Interact_Send_SEI", nil) forState:(UIControlStateNormal)];
    
    [self.beautyControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Compose", nil) forState:(UIControlStateNormal)];
    [self.filterControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Filter", nil) forState:(UIControlStateNormal)];
    [self.stickerControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Sticker", nil) forState:(UIControlStateNormal)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
