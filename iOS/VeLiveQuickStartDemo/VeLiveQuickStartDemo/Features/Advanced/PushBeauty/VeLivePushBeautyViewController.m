/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePushBeautyViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//
/*
Camera push stream, integrate intelligent beautification special effects
 
 This document shows how to integrate camera push stream and intelligent beautification special effects
 1. First integrate intelligent beautification special effects SDK, recommend integrating dynamic library
 2, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 3, set the preview API: [self.livePusher setRenderView: self.view];
 4, open the microphone capture API: [self.livePusher startAudioCapture: (VeLiveAudioCaptureMicrophone) ];
 5, open the camera capture API: [self.livePusher startVideoCapture: (VeLiveVideoCaptureFrontCamera) ];
 6, start streaming API: [self.livePusher startPush: @"rtmp://push.example.com/rtmp"];
 7, initial test beauty related parameters API: [[self.livePusher getVideoEffectManager] setupWithConfig: [[VeLiveVideoEffectLicenseConfiguration alloc] initWithPath: licensePath]];
 8, set the model effect
 9、Setup Beauty API: [[self.livePusher getVideoEffectManager] setComposeNodes:@[]];
 10、Setup Filter API: [[self.livePusher getVideoEffectManager] setFilter:@""];
 11、Setup Sticker API: [[self.livePusher getVideoEffectManager] setSticker:@""];
 */
#import "VeLivePushBeautyViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePushBeautyViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerControlBtn;
@property (nonatomic, strong) VeLivePusher *livePusher;
@end

@implementation VeLivePushBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupLivePusher];
    [self setupEffectSDK];
}

- (void)dealloc {
    //  Destroy the thruster
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    [self.livePusher destroy];
}

- (void)setupLivePusher {
    
    //  Create a pusher
    self.livePusher = [[VeLivePusher alloc] initWithConfig:[[VeLivePusherConfiguration alloc] init]];
    
    //  Configure preview view
    [self.livePusher setRenderView:self.view];
    
    //  Set the pusher callback
    [self.livePusher setObserver:self];
    
    //  Set periodic information callbacks
    [self.livePusher setStatisticsObserver:self interval:3];
    
    //  Request camera and microphone permissions
    [VeLiveDeviceCapture requestCameraAndMicroAuthorization:^(BOOL cameraGranted, BOOL microGranted) {
        if (cameraGranted) {
            //  Start video capture
            [self.livePusher startVideoCapture:(VeLiveVideoCaptureFrontCamera)];
        } else {
            NSLog(@"VeLiveQuickStartDemo: Please Allow Camera Auth");
        }
        if (microGranted) {
            //  Start audio capture
            [self.livePusher startAudioCapture:(VeLiveAudioCaptureMicrophone)];
        } else {
            NSLog(@"VeLiveQuickStartDemo: Please Allow Microphone Auth");
        }
    }];
}

- (void)setupEffectSDK {
    //  Note: This method only takes effect when the SDK of intelligent beautification special effects has been integrated in the project
    VeLiveVideoEffectManager *effectManager = [self.livePusher getVideoEffectManager];
    //  Effects Authentication License path, please find the correct path according to the project configuration
    NSString *licensePath =  [NSString stringWithFormat:@"LicenseBag.bundle/%@", EFFECT_LICENSE_NAME];
    licensePath = [NSBundle.mainBundle pathForResource:licensePath ofType:nil];
    //  Effect model effect package path
    NSString *algoModelPath = [NSBundle.mainBundle pathForResource:@"ModelResource.bundle" ofType:nil];
    
    if (![NSFileManager.defaultManager fileExistsAtPath:licensePath]) {
        return;
    }
    //  Create Beauty Configuration
    VeLiveVideoEffectLicenseConfiguration *licConfig = [[VeLiveVideoEffectLicenseConfiguration alloc] initWithPath:licensePath];
    //  Set Beauty Configuration
    [effectManager setupWithConfig:licConfig];
    //  Set algorithm package path
    [effectManager setAlgoModelPath:algoModelPath];
    
    //  Turn on beauty effects
    if ([effectManager setEnable:YES] != 0) {
        NSLog(@"VeLiveQuickStartDemo: license unavailabel, please check");
    }
}

- (IBAction)pushControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        self.infoLabel.text = NSLocalizedString(@"config_stream_name_tip", nil);
        return;
    }
    if (!sender.isSelected) {
        self.infoLabel.text = NSLocalizedString(@"Generate_Push_Url_Tip", nil);
        self.view.userInteractionEnabled = NO;
        [VeLiveURLGenerator genPushURLForApp:LIVE_APP_NAME
                                  streamName:self.urlTextField.text
                                  completion:^(VeLiveURLRootModel<VeLivePushURLModel *> * _Nullable model, NSError * _Nullable error) {
            self.infoLabel.text = error.localizedDescription;
            self.view.userInteractionEnabled = YES;
            if (error != nil) {
                return;
            }
            //  Start pushing the stream, push the stream address support: rtmp protocol, http protocol (RTM)
            [self.livePusher startPush:[model.result getRtmpPushUrl]];
            sender.selected = !sender.isSelected;
        }];
    } else {
        //  Stop streaming
        [self.livePusher stopPush];
        sender.selected = !sender.isSelected;
    }
}

- (IBAction)beautyControl:(UIButton *)sender {
    //  According to the effect package, find the correct resource path, generally to the reshape_lite, beauty_IOS_lite directory
    NSString *beautyPath = [NSBundle.mainBundle pathForResource:@"ComposeMakeup.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:beautyPath]) {
        return;
    }
    //  Set up beauty effect package
    [self.livePusher.getVideoEffectManager setComposeNodes:@[beautyPath]];
    //  Set the beauty effect intensity, NodeKey can be obtained in the config_file under the effect package, if there is no config_file, please contact the business consultation
    [self.livePusher.getVideoEffectManager updateComposerNodeIntensity:beautyPath nodeKey:@"whiten" intensity:0.5];
}

- (IBAction)filterControl:(UIButton *)sender {
    //  Filter effect package, find the correct resource path, generally to the Filter_01_xx directory
    
    NSString *filterPath = [NSBundle.mainBundle pathForResource:@"FilterResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:filterPath]) {
        return;
    }
    //  Set the filter effect package path
    [self.livePusher.getVideoEffectManager setFilter:filterPath];
    //  Set filter effect intensity
    [self.livePusher.getVideoEffectManager updateFilterIntensity:0.5];
}

- (IBAction)stickerControl:(UIButton *)sender {
    //  Sticker effect package, find the correct resource path, generally to the stickers_xxx directory

    NSString *stickerPath = [NSBundle.mainBundle pathForResource:@"StickerResource.bundle/xxx" ofType:nil];
    if (![NSFileManager.defaultManager fileExistsAtPath:stickerPath]) {
        return;
    }
    //  Set the sticker effect package path
    [self.livePusher.getVideoEffectManager setSticker:stickerPath];
}

// MARK: - VeLivePusherObserver
- (void)onError:(int)code subcode:(int)subcode message:(nullable NSString *)msg {
    NSLog(@"VeLiveQuickStartDemo: Error %d-%d-%@", code, subcode, msg?:@"");
}

- (void)onStatusChange:(VeLivePushStatus)status {
    NSLog(@"VeLiveQuickStartDemo: Status %@", @(status));
}

// MARK: - VeLivePusherStatisticsObserver
- (void)onStatistics:(VeLivePusherStatistics *)statistics {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoLabel.attributedText = [VeLiveSDKHelper getPushInfoString:statistics];
    });
}

- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Push_Beauty", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlLabel.text = NSLocalizedString(@"Push_Url_Tip", nil);
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
    
    [self.beautyControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Compose", nil) forState:(UIControlStateNormal)];
    [self.filterControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Filter", nil) forState:(UIControlStateNormal)];
    [self.stickerControlBtn setTitle:NSLocalizedString(@"Push_Beauty_Sticker", nil) forState:(UIControlStateNormal)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
