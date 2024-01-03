/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveLinkAnchorViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//

#import "VeLiveLinkAnchorViewController.h"
#import "VeLiveAnchorManager.h"

@interface VeLiveLinkAnchorViewController () <VeLiveAnchorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *seiControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *interactControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerControlBtn;
@property (weak, nonatomic) IBOutlet UIStackView *remoteStackView;
//  Live streaming host View
@property (nonatomic, strong) IBOutlet UIView *previewView;
//  List of users participating in Lianmai
@property (nonatomic, strong) NSMutableArray <NSString *> *usersInRoom;
//  Remote user view list during Lianmai process
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIView *> *remoteUserViews;
//  Live streaming host + Lianmai manager
@property (nonatomic, strong) VeLiveAnchorManager *liveAnchorManager;
@end

@implementation VeLiveLinkAnchorViewController

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
    self.usersInRoom = [NSMutableArray arrayWithCapacity:6];
    self.remoteUserViews = [[NSMutableDictionary alloc] initWithCapacity:6];
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
}

- (void)stopPush {
    [self.liveAnchorManager stopPush];
}

- (void)clearInteractUsers {
    //  Start Lianmai
    //  Clear historical users, business logic processing
    [self.usersInRoom removeAllObjects];
    [self.remoteUserViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.remoteUserViews removeAllObjects];
}
- (void)startInteractive {
    [self clearInteractUsers];
    //  Start Lianmai
    [self.liveAnchorManager startInteract:self.roomID
                                    token:self.token
                                 delegate:self];
}

- (void)stopInteractive {
    [self clearInteractUsers];
    
    //  Stop Lianmai
    [self.liveAnchorManager stopInteract];
}

- (IBAction)pushControl:(UIButton *)sender {
    if (!sender.isSelected) {
        [self startPush];
    } else {
        [self stopPush];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)interactControl:(UIButton *)sender {
    if (!sender.isSelected) {
        [self startInteractive];
    } else {
        [self stopInteractive];
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
    UIView *remoteview = [self.remoteUserViews objectForKey:uid];
    if (remoteview == nil) {
        remoteview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
        [self.remoteUserViews setObject:remoteview forKey:uid];
    }
    [self.remoteStackView addArrangedSubview:remoteview];
    
    [manager setRemoteVideoView:remoteview forUid:uid];
    
    //  Update layout parameters
    [manager updateLiveTranscodingLayout:[self rtcLayout]];
}

- (void)manager:(VeLiveAnchorManager *)manager onUserUnPublishStream:(nonnull NSString *)uid type:(ByteRTCMediaStreamType)streamType reason:(ByteRTCStreamRemoveReason)reason {
    if (streamType == ByteRTCMediaStreamTypeAudio) {
        return;
    }
    [self.usersInRoom removeObject:uid];
    UIView *remoteView = [self.remoteUserViews objectForKey:uid];
    [self.remoteStackView removeArrangedSubview:remoteView];
    [self.remoteUserViews removeObjectForKey:uid];
    
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
    __block NSUInteger guestIndex = 0;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat guestX = (viewWidth - 130) / viewWidth;
    CGFloat guestStartY = (viewHeight - 42) / viewHeight;
    [self.usersInRoom enumerateObjectsUsingBlock:^(NSString * _Nonnull uid, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ByteRTCMixedStreamLayoutRegionConfig *region = [[ByteRTCMixedStreamLayoutRegionConfig alloc]init];
        region.userID          = uid;
        region.roomID       = self.roomID;
        region.isLocalUser    = [uid isEqualToString:self.userID]; //  Determine whether it is the current live streaming host
        region.renderMode   = ByteRTCMixedStreamRenderModeHidden;
        
        if (region.isLocalUser) { // Current live streaming host location, for reference only
            region.locationX        = 0.0;
            region.locationY        = 0.0;
            region.widthProportion    = 1;
            region.heightProportion   = 1;
            region.zOrder   = 0;
            region.alpha    = 1.0;
        } else { //  Remote user location, for reference only
            region.locationX        = guestX;
            //  130 is the width and height of the small windows, 8 is the spacing of the small windows
            region.locationY        = guestStartY - (130.0 * (guestIndex + 1) + guestIndex * 8) / viewHeight;
            region.widthProportion    = (130.0 / viewWidth);
            region.heightProportion   = (130.0 / viewHeight);
            region.zOrder   = 1;
            region.alpha    = 1;
            guestIndex ++;
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
    
    [self.interactControlBtn setTitle:NSLocalizedString(@"Interact_Start_Link", nil) forState:(UIControlStateNormal)];
    [self.interactControlBtn setTitle:NSLocalizedString(@"Interact_Stop_Link", nil) forState:(UIControlStateSelected)];
    
    [self.seiControlBtn setTitle:NSLocalizedString(@"Interact_Send_SEI", nil) forState:(UIControlStateNormal)];
    
    [self.beautyControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Compose", nil) forState:(UIControlStateNormal)];
    [self.filterControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Filter", nil) forState:(UIControlStateNormal)];
    [self.stickerControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Sticker", nil) forState:(UIControlStateNormal)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
