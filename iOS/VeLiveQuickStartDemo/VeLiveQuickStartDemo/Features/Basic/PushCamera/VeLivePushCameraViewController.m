/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePushCameraViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/12/04.
//
/*
Camera push stream
 This document shows how to integrate the camera push stream function
 1, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 2, set the preview view API: [self.livePusher setRenderView: self.view];
 3, open the microphone capture API: [self.livePusher startAudioCapture: (VeLiveAudioCaptureMicrophone) ];
 4, open the camera capture API: [self.livePusher startVideoCapture: (VeLiveVideoCaptureFrontCamera) ];
 5, start pushing the stream API: [self.livePusher startPush: @"rtmp://push.example.com/rtmp"];
 */
#import "VeLivePushCameraViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePushCameraViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *captureMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *previewMirrorBtn;
@property (weak, nonatomic) IBOutlet UIButton *pushMirrorBtn;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) VeLivePusher *livePusher;
@end

@implementation VeLivePushCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self addApplicationNotifaction];
    [self setupLivePusher];
}

- (void)dealloc {
    //  Destroy the thruster
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    [self.livePusher destroy];
}

- (void)applicationWillResignActive:(NSNotification *)noti {
    //  Enter the background and continue to push the last frame.
    //  You can also continue to push a picture, or push a black frame, see the API for details.
    [self.livePusher switchVideoCapture:(VeLiveVideoCaptureLastFrame)];
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    //  Enter the foreground and switch to camera capture.
    [self.livePusher switchVideoCapture:(VeLiveVideoCaptureFrontCamera)];
}

- (void)setupLivePusher {
    //  Push stream configuration
    VeLivePusherConfiguration *config = [[VeLivePusherConfiguration alloc] init];
    //  Number of failed reconnections
    config.reconnectCount = 10;
    //  Time interval for reconnection
    config.reconnectIntervalSeconds = 5;
    
    //  Create a pusher
    self.livePusher = [[VeLivePusher alloc] initWithConfig:config];
    
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

- (IBAction)pushControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config Url");
        return;
    }
    if (!sender.isSelected) {
        //  Start pushing the stream, push the stream address support: rtmp protocol, http protocol (RTM)
        [self.livePusher startPush:self.urlTextField.text];
    } else {
        //  Stop streaming
        [self.livePusher stopPush];
    }
    
    sender.selected = !sender.isSelected;
}

- (IBAction)cameraControl:(UIButton *)sender {
    if (sender.isSelected) {
        //  Switch to front-facing camera
        [self.livePusher switchVideoCapture:(VeLiveVideoCaptureFrontCamera)];
    } else {
        //  Switch to rear camera
        [self.livePusher switchVideoCapture:(VeLiveVideoCaptureBackCamera)];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)muteControl:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    //  Mute/Unmute
    [self.livePusher setMute:sender.isSelected];
}

- (IBAction)captureMirror:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    //  Turn capture image on/off
    [self.livePusher setVideoMirror:(VeLiveVideoMirrorCapture) enable:sender.isSelected];
}

- (IBAction)previewMirror:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    //  Turn preview image on/off
    [self.livePusher setVideoMirror:(VeLiveVideoMirrorPreview) enable:sender.isSelected];
}

- (IBAction)pushMirror:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    //  Turn streaming mirrors on/off
    [self.livePusher setVideoMirror:(VeLiveVideoMirrorPushStream) enable:sender.isSelected];
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
    self.title = NSLocalizedString(@"Camera_Push", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlTextField.text = LIVE_PUSH_URL;
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
    [self.cameraControlBtn setTitle:NSLocalizedString(@"Push_Camera_Front", nil) forState:(UIControlStateNormal)];
    [self.cameraControlBtn setTitle:NSLocalizedString(@"Push_Camera_Back", nil) forState:((UIControlStateSelected))];
    [self.muteControlBtn setTitle:NSLocalizedString(@"Push_Mute", nil) forState:((UIControlStateNormal))];
    [self.muteControlBtn setTitle:NSLocalizedString(@"Push_UnMute", nil) forState:((UIControlStateSelected))];
    [self.captureMirrorBtn setTitle:NSLocalizedString(@"Push_Capture_Mirror", nil) forState:((UIControlStateNormal))];
    [self.previewMirrorBtn setTitle:NSLocalizedString(@"Push_Preview_Mirror", nil) forState:((UIControlStateNormal))];
    [self.pushMirrorBtn setTitle:NSLocalizedString(@"Push_Push_Mirror", nil) forState:((UIControlStateNormal))];
}

- (void)addApplicationNotifaction {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationWillResignActive:)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationDidBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
