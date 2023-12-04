/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePushRTMViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/12/04.
//
/*
Camera ultra-low latency push stream
 
 This file shows how to integrate camera ultra-low latency push stream
 1, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 2, set the preview view API: [self.livePusher setRenderView: self.view];
 3, open the microphone capture API: [self.livePusher startAudioCapture: (VeLiveAudioCaptureMicrophone) ];
 4, open the camera capture API: [self.livePusher startVideoCapture: (VeLiveVideoCaptureFrontCamera) ];
 5, start pushing the stream API: [self.livePusher startPushWithUrls: @[@"http://push.example.com/rtm.sdp", @"rtmp://push.example.com/rtmp"]];
 */
#import "VeLivePushRTMViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePushRTMViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *rtmUrlTextField;
@property (weak, nonatomic) IBOutlet UITextField *rtmpUrlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (nonatomic, strong) VeLivePusher *livePusher;
@end

@implementation VeLivePushRTMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupLivePusher];
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

- (IBAction)pushControl:(UIButton *)sender {
    if (self.rtmUrlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config RTM Url");
        return;
    }
    if (self.rtmpUrlTextField.text.length <= 0) {
        NSLog(@"VeLiveQuickStartDemo: Please Config RTMP Url");
        return;
    }
    if (!sender.isSelected) {
        //  Start the push stream, fill in the RTM push stream address for the first push stream address, and fill in the downgrade push stream address later.
        [self.livePusher startPushWithUrls:@[self.rtmUrlTextField.text, self.rtmpUrlTextField.text]];
    } else {
        //  Stop streaming
        [self.livePusher stopPush];
    }
    
    sender.selected = !sender.isSelected;
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
    self.title = NSLocalizedString(@"Push_RTM", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.rtmpUrlTextField.text = LIVE_PUSH_URL;
    self.rtmUrlTextField.text = LIVE_RTM_PUSH_URL;
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
