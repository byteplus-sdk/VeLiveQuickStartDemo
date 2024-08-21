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

#import "VeLiveScreenCaptureViewController.h"
#import "VeLiveSDKHelper.h"

@interface VeLiveScreenCaptureViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver, VeLiveScreenCaptureStatusObserver>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (nonatomic, strong) VeLivePusher *livePusher;
@property (nonatomic, copy) NSString *streamUrl;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) RPSystemBroadcastPickerView *broadcastPickerView API_AVAILABLE(ios(12.0));
@end

@implementation VeLiveScreenCaptureViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupLivePusher];
    [self setupBroadcastPicker];
}

- (void)dealloc {
    [self stopTimer];
    //  Destroy the thruster
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    [self.livePusher destroy];
}

- (void)setupBroadcastPicker {
    if (@available(iOS 12.0, *)) {
        self.broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        self.broadcastPickerView.hidden = YES;
        self.broadcastPickerView.showsMicrophoneButton = NO;
        self.broadcastPickerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
#ifdef APP_SC_GROUP_ID
        self.broadcastPickerView.preferredExtension = @SC_PRODUCT_BUNDLE_IDENTIFIER;
#else
        NSAssert(NO, @"please config APP_SC_GROUP_ID in Common.xcconfig");
#endif
        [self.view addSubview:self.broadcastPickerView];
    }
}

- (void)setupLivePusher {
    
    //  Create a pusher
    self.livePusher = [[VeLivePusher alloc] initWithConfig:[[VeLivePusherConfiguration alloc] init]];
    
    // Setup Screen Capture Encode
    VeLiveVideoEncoderConfiguration *video = [[VeLiveVideoEncoderConfiguration alloc] initWithResolution:VeLiveVideoResolutionScreen];
    [self.livePusher setVideoEncoderConfiguration:video];
    
    //  Set the pusher callback
    [self.livePusher setObserver:self];
    
    //  Set periodic information callbacks
    [self.livePusher setStatisticsObserver:self interval:3];
    
    // set screen capture observer
    [self.livePusher setScreenCaptureObserver:self];
    
    //  Request microphone permissions
    [VeLiveDeviceCapture requestMicrophoneAuthorization:^(BOOL granted) {
        if (!granted) {
            NSLog(@"VeLiveQuickStartDemo: Please Allow Microphone Auth");
        }
    }];
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
            self.streamUrl = [model.result getRtmpPushUrl];
            [self startBroadcast];
#ifdef APP_SC_GROUP_ID
            // start screen capture
            [self.livePusher startScreenCapture:@APP_SC_GROUP_ID];
#else
            NSAssert(NO, @"please config APP_SC_GROUP_ID in Common.xcconfig");
#endif
        }];
    } else {
        [self stopBroadcast];
        //  Stop streaming
        [self.livePusher stopScreenCapture];
    }
}

- (void)startBroadcast {
    if (@available(iOS 12.0, *)) {
        if (self.broadcastPickerView != nil) {
            for (UIView* view in self.broadcastPickerView.subviews) {
                UIButton* button = (UIButton*)view;
                [button sendActionsForControlEvents:UIControlEventAllTouchEvents];
            }
        }
    } else {
        NSLog(@"VeLiveQuickStartDemo: below iOS 12 not support screen sharing");
    }
}

- (void)stopBroadcast {
    if (@available(iOS 12.0, *)) {
        if (self.broadcastPickerView != nil) {
            for (UIView* view in self.broadcastPickerView.subviews) {
                UIButton* button = (UIButton*)view;
                [button sendActionsForControlEvents:UIControlEventAllTouchEvents];
            }
        }
    } else {
        NSLog(@"VeLiveQuickStartDemo: below iOS 12 not support screen sharing");
    }
}

// MARK: -  VeLiveScreenCaptureStatusObserver delegate

- (void)broadcastStarted {
    if (self.streamUrl == nil) {
        [self stopBroadcast];
        [self.livePusher stopScreenCapture];
        return;
    }
    if (!self.pushControlBtn.isSelected) {
        self.pushControlBtn.selected = YES;
    }
    [self startTimer];
    // Start audio capture
    [self.livePusher startAudioCapture:VeLiveAudioCaptureMicrophone];
    // Start push
    [self.livePusher startPush:self.streamUrl];
}

- (void)broadcastPaused {
}

- (void)broadcastResumed {
}

- (void)broadcastFinished {
    [self stopTimer];
    if (self.pushControlBtn.isSelected) {
        self.pushControlBtn.selected = NO;
    }
    // Stop audio capture
    [self.livePusher stopAudioCapture];
    // Stop push
    [self.livePusher stopPush];
}

- (void)startTimer {
    if (self.timer == nil) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"HH:mm:ss.SSS";
        __weak __typeof__(self)weakSelf = self;
        self.timer = [NSTimer timerWithTimeInterval:1/30.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.timeLabel.text = [self.dateFormatter stringFromDate:NSDate.date];
        }];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [self.timer fire];
    }
}

- (void)stopTimer {
    if (self.timer != nil) {
        if (self.timer.isValid) {
            [self.timer invalidate];
        }
        self.timer = nil;
        self.timeLabel.text = nil;
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

- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Home_Screen_Push", nil);
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
