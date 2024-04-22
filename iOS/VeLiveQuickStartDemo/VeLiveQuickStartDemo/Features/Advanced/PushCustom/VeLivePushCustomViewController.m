/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePushCustomViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2023/6/28.
//
/*
Custom capture push stream
 
 This file shows how to integrate custom audio & video capture push stream
 1, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 2, set the preview view API: [self.livePusher setRenderView: self.view];
 3, open the microphone external capture API: [self.livePusher startAudioCapture: (VeLiveAudioCaptureExternal) ];
 4, open the camera external capture API: [self.livePusher startVideoCapture: (VeLiveVideoCaptureExternal) ];
 5 Send external audio frame data API: [self.livePusher pushExternalAudioFrame: [[VeLiveAudioFrame alloc] init]]
 6, send external video frame data API: [self.livePusher pushExternalAudioFrame: [[pushExternalVideoFrame alloc] init]]
 7, start pushing the stream API: [self.livePusher startPush: @"rtmp://push.example.com/rtmp"];
 */
#import "VeLivePushCustomViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePushCustomViewController () <VeLiveDeviceCaptureDelegate, VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) VeLiveDeviceCapture *deviceCapture;
@property (nonatomic, strong) VeLivePusher *livePusher;
@end

@implementation VeLivePushCustomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupCustomCapture];
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
    
    //  Enable external video capture
    [self.livePusher startVideoCapture:(VeLiveVideoCaptureExternal)];
    
    //  Turn on external audio capture
    [self.livePusher startAudioCapture:(VeLiveAudioCaptureExternal)];
    
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

// MARK: - VeLiveDeviceCaptureDelegate
- (void)capture:(VeLiveDeviceCapture *)capture didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    VeLiveVideoFrame *videoFrame = [[VeLiveVideoFrame alloc] init];
    videoFrame.bufferType = VeLiveVideoBufferTypeSampleBuffer;
    videoFrame.sampleBuffer = sampleBuffer;
    videoFrame.rotation = VeLiveVideoRotation0;
    [self.livePusher pushExternalVideoFrame:videoFrame];
}

- (void)capture:(VeLiveDeviceCapture *)capture didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    VeLiveAudioFrame *frame = [[VeLiveAudioFrame alloc] init];
    frame.bufferType = VeLiveAudioBufferTypeSampleBuffer;
    frame.sampleBuffer = sampleBuffer;
    frame.pts = CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000000);
    [self.livePusher pushExternalAudioFrame:frame];
}

- (void)setupCustomCapture {
    self.deviceCapture = [[VeLiveDeviceCapture alloc] init];
    self.deviceCapture.delegate = self;
    [self.deviceCapture startCapture];
}

- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Push_Custom", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlLabel.text = NSLocalizedString(@"Push_Url_Tip", nil);
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
