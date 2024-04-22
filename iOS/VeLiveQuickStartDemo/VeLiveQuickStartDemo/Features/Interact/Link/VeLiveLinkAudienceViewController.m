/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLiveLinkAudienceViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//

#import "VeLiveLinkAudienceViewController.h"
#import "VeLiveAudienceManager.h"
@interface VeLiveLinkAudienceViewController () <VeLiveAudienceDelegate>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *interactControlBtn;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *beautyControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *seiControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *playControlBtn;
@property (weak, nonatomic) IBOutlet UIStackView *remoteStackView;
//  List of users participating in Lianmai
@property (nonatomic, strong) NSMutableArray <NSString *> *usersInRoom;
//  Local User View during Lianmai Process
@property (nonatomic, strong) IBOutlet UIView *localView;
//  Remote user view list during Lianmai process
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIView *> *remoteUserViews;
@property (nonatomic, strong) VeLiveAudienceManager *audienceManager;
@end

@implementation VeLiveLinkAudienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupAudienceManager];
    [self setupEffectSDK];
}

- (void)dealloc {
    //  Destroy Lianmai Manager
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    if (self.audienceManager != nil) {
        [self.audienceManager destory];
        self.audienceManager = nil;
    }
}

- (void)setupAudienceManager {
    self.usersInRoom = [NSMutableArray arrayWithCapacity:6];
    self.remoteUserViews = [[NSMutableDictionary alloc] initWithCapacity:6];
    self.audienceManager = [[VeLiveAudienceManager alloc] initWithAppId:RTC_APPID
                                                                 userId:self.userID];
    [self.audienceManager setLocalVideoView:self.localView];
    [self startPlay];
}

- (void)startPlay {
    if (self.urlTextField.text <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please config pull url");
        return;
    }
    [self.audienceManager startPlay:self.urlTextField.text];
}

- (void)clearInteractUsers {
    //  Start Lianmai
    //  Clear historical users, business logic processing
    [self.usersInRoom removeAllObjects];
    [self.remoteUserViews.allValues enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.remoteStackView removeArrangedSubview:obj];
    }];
}

- (void)startInteractive {
    [self clearInteractUsers];
    [self.remoteUserViews removeAllObjects];
    [self.audienceManager startInteract:self.roomID token:self.token delegate:self];
}

- (void)stopInteractive {
    //  Clear historical users, business logic processing
    [self clearInteractUsers];
    
    //  Stop Lianmai
    [self.audienceManager stopInteract];
}

- (IBAction)playControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        self.infoLabel.text = NSLocalizedString(@"config_stream_name_tip", nil);
        return;
    }
    if (sender.isSelected) {
        //  Stop playing
        [self.audienceManager stopPlay];
        sender.selected = !sender.isSelected;
    } else {
        self.infoLabel.text = NSLocalizedString(@"Generate_Pull_Url_Tip", nil);
        self.view.userInteractionEnabled = NO;
        [VeLiveURLGenerator genPullURLForApp:LIVE_APP_NAME streamName:self.urlTextField.text completion:^(VeLiveURLRootModel<VeLivePullURLModel *> * _Nullable model, NSError * _Nullable error) {
            self.infoLabel.text = error.localizedDescription;
            self.view.userInteractionEnabled = YES;
            if (error != nil) {
                return;
            }
            // start play
            [self.audienceManager startPlay:[model.result getUrlWithProtocol:@"flv"]];
            sender.selected = !sender.isSelected;
        }];
    }
}

- (IBAction)interactControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config Url");
        return;
    }
    if (!sender.isSelected) {
        [self startInteractive];
    } else {
        [self stopInteractive];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)seiControl:(UIButton *)sender {
    [self.audienceManager sendSeiMessage:@"audience_test_sei_for_interactive" repeat:20];
}


- (void)setupEffectSDK {
    //  Note: This method only takes effect when the SDK of intelligent beautification special effects has been integrated in the project
    ByteRTCVideo *rtcVideo = self.audienceManager.rtcVideo;
    
    //  Effects Authentication License path, please find the correct path according to the project configuration
    NSString *licensePath = [NSString stringWithFormat:@"LicenseBag.bundle/%@", EFFECT_LICENSE_NAME];
    licensePath = [NSBundle.mainBundle pathForResource:licensePath ofType:nil];
    
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
    [self.audienceManager.rtcVideo.getVideoEffectInterface setEffectNodes:@[beautyPath]];
    //  Set the beauty effect intensity, NodeKey can be obtained in the config_file under the effect package, if there is no config_file, please contact the business consultation
    [self.audienceManager.rtcVideo.getVideoEffectInterface updateEffectNode:beautyPath key:@"whiten" value:0.5];
}

- (IBAction)filterControl:(UIButton *)sender {
    //  Filter effect package, find the correct resource path, generally to the Filter_01_xx directory
    NSString *filterPath = [NSBundle.mainBundle pathForResource:@"FilterResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:filterPath]) {
        return;
    }
    [self.audienceManager.rtcVideo.getVideoEffectInterface setColorFilter:filterPath];
    [self.audienceManager.rtcVideo.getVideoEffectInterface setColorFilterIntensity:0.5];
}

- (IBAction)stickerControl:(UIButton *)sender {
    //  Sticker effect package, find the correct resource path, generally to the stickers_xxx directory
    NSString *stickerPath = [NSBundle.mainBundle pathForResource:@"StickerResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:stickerPath]) {
        return;
    }
    [self.audienceManager.rtcVideo.getVideoEffectInterface appendEffectNodes:@[stickerPath]];
}


// MARK: - VeLiveAudienceDelegate
- (void)manager:(VeLiveAudienceManager *)manager onUserJoined:(NSString *)uid {
    
}

- (void)manager:(VeLiveAudienceManager *)manager onUserLeave:(NSString *)uid {
    
}

- (void)manager:(VeLiveAudienceManager *)manager onJoinRoom:(NSString *)uid {
    
}

- (void)manager:(VeLiveAudienceManager *)manager onUserPublishStream:(nonnull NSString *)uid type:(ByteRTCMediaStreamType)streamType {
    if (streamType == ByteRTCMediaStreamTypeAudio) {
        return;
    }
    //  Setting up remote user views
    UIView *remoteView = [self.remoteUserViews objectForKey:uid];
    if (remoteView == nil) {
        remoteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
        [self.remoteUserViews setObject:remoteView forKey:uid];
    }
    [self.remoteStackView addArrangedSubview:remoteView];
    [manager setRemoteVideoView:remoteView forUid:uid];
}

- (void)manager:(VeLiveAudienceManager *)manager onUserUnPublishStream:(nonnull NSString *)uid type:(ByteRTCMediaStreamType)streamType reason:(ByteRTCStreamRemoveReason)reason {
    if (streamType == ByteRTCMediaStreamTypeAudio) {
        return;
    }
    UIView *remoteView = [self.remoteUserViews objectForKey:uid];
    if (remoteView != nil) {
        [self.remoteStackView removeArrangedSubview:remoteView];
        [self.remoteUserViews removeObjectForKey:uid];
    }
    [manager setRemoteVideoView:nil forUid:uid];
}


- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Interact_Link_Audience_Title", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlLabel.text = NSLocalizedString(@"Pull_Stream_Url_Tip", nil);
    [self.playControlBtn setTitle:NSLocalizedString(@"Pull_Stream_Start_Play", nil) forState:(UIControlStateNormal)];
    [self.playControlBtn setTitle:NSLocalizedString(@"Pull_Stream_Stop_Play", nil) forState:(UIControlStateSelected)];
    
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
