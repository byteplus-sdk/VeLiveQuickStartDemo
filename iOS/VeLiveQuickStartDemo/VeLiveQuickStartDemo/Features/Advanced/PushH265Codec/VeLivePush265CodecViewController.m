/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePush265CodecViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/12/04.
//
/*
H265 encoding push stream
 
 This document shows how to integrate H265 encoding capability
 1, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 2, initial encoding configuration API: VeLiveVideoEncoderConfiguration * videoEncodeCfg = [[LiveVideoEncoderConfiguration alloc] initWithResolution: (VeLiveoVideResolution720P) ]
 3, configuration encoding type API: videoEncodeCfg.codec = VeLiveVideoCodecByteVC1;
 4, set the encoding configuration API: [self.livePusher setVideoEncoderConfiguration: videoEncodeCfg];
 5, set the preview view API: [self.livePusher setRenderView: self.view];
 6, open the microphone capture API: [self.livePusher startAudioCapture: (VeLiveAudioCaptureMicrophone) ];
 7, open the camera capture API: [self.livePusher startVideoCapture: (VeLiveVideoCaptureFrontCamera) ];
 8, start the stream API: [self.livePusher startPush: @"rtmp://push.example.com/rtmp"];
 */
#import "VeLivePush265CodecViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePush265CodecViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (nonatomic, strong) VeLivePusher *livePusher;

@end

@implementation VeLivePush265CodecViewController

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
    
    //  Video encoding configuration
    VeLiveVideoEncoderConfiguration *videoEncodeCfg = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:(VeLiveVideoResolution720P)];
    
    //  encoding type
    videoEncodeCfg.codec = VeLiveVideoCodecByteVC1;
    
    //  Configuration coding
    [self.livePusher setVideoEncoderConfiguration:videoEncodeCfg];
    
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
    self.title = NSLocalizedString(@"Push_Auto_Bitrate", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlTextField.text = LIVE_PUSH_URL;
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
