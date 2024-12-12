/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  VeLivePushMixStreamViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2024/11/21.
//

/*
 Push stream mixed into audio & video stream at the same time
 
 This file shows how to integrate camera push stream and audio and video mixing function
 1, initialize the push stream API: self.livePusher = [[VeLivePusher alloc] initWithConfig: [[VeLivePusherConfiguration alloc] init]];
 2, set the preview view API: [self.livePusher setRenderView: self.view];
 3, open the microphone capture API: [self.livePusher to start AudioCapture: (VeLiveAudioCaptureMicrophone) ];
 4, open the camera capture API: [self.livePusher to start VideoCapture: (VeLiveVideoCaptureFrontCamera) ];
 5, start the stream API: [self.livePusher to start Push: @"rtmp://push.example.com/rtmp"];
 6, set the audio mixing API:
    self.videoMixID = [self.livePusher.getMixerManager addVideoStream];
     [self.livePusher.getMixerManager sendCustomAudioFrame: audioFrame streamId: self.audioMixID];
 7, set the video mixing API:
    self.videoMixID = [self.livePusher.getMixerManager addVideoStream];
     [self.livePusher.getMixerManager updateStreamMixDescription: dec];
     [self.livePusher.getMixerManager sendCustomVideoFrame: videoFrame streamId: self.videoMixID];
 */

#import "VeLivePushMixStreamViewController.h"
#import "VeLiveSDKHelper.h"
#import "VeLiveFileReader.h"
@interface VeLivePushMixStreamViewController () <VeLivePusherObserver, VeLivePusherStatisticsObserver>
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *pushControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *mixAudioControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *mixVideoControlBtn;
@property (nonatomic, strong) VeLivePusher *livePusher;
@property (nonatomic, strong) VeLiveFileReader *auidoFileReader;
@property (nonatomic, strong) VeLiveFileReader *videoFileReader;
@property (nonatomic) int audioMixID;
@property (nonatomic) int videoMixID;
@end

@implementation VeLivePushMixStreamViewController

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

- (IBAction)audioStreamControl:(UIButton *)sender {
    BOOL isSelected = sender.isSelected;
    if (!isSelected) {
        //  Add audio stream, and locally render
        self.audioMixID = [self.livePusher.getMixerManager addAudioStream:VeLiveAudioMixPlayAndPush];
        VELAudioFileConfig *config = [[VELAudioFileConfig alloc] init];
        config.fileType = VELAudioFileType_PCM;
        config.channels = 2;
        config.name = @"audio_44100_16bit2ch.pcm";
        config.path = [NSBundle.mainBundle pathForResource:@"audio_44100_16bit_2ch.pcm" ofType:nil];
        self.auidoFileReader = [VeLiveFileReader readerWithConfig:config];
        self.auidoFileReader.repeat = YES;
        [self.auidoFileReader startWithDataCallBack:^(NSData * _Nullable data, CMTime pts) {
            VeLiveAudioFrame *audioFrame = [[VeLiveAudioFrame alloc] init];
            audioFrame.bufferType = VeLiveAudioBufferTypeNSData;
            audioFrame.data = data;
            audioFrame.sampleRate = config.sampleRate;
            audioFrame.channels = config.channels;
            audioFrame.pts = pts;
            //  Mix in audio streams
            [self.livePusher.getMixerManager sendCustomAudioFrame:audioFrame streamId:self.audioMixID];
        } completion:^(NSError * _Nullable error, BOOL isEnd) {
            vel_sync_main_queue(^{
                [self.auidoFileReader stop];
                [self.livePusher.getMixerManager removeAudioStream:self.audioMixID];
                sender.selected = NO;
                
            });
        }];
        sender.selected = YES;
    } else {
        [self.auidoFileReader stop];
        [self.livePusher.getMixerManager removeAudioStream:self.audioMixID];
        sender.selected = NO;
    }
}

- (IBAction)videoStreamControl:(UIButton *)sender {
    BOOL isSelected = sender.isSelected;
    if (!isSelected) {
        //  Add video stream
        self.videoMixID = [self.livePusher.getMixerManager addVideoStream];
        
        VeLiveStreamMixDescription *dec = [[VeLiveStreamMixDescription alloc] init];
        VeLiveMixVideoLayout *layout = [[VeLiveMixVideoLayout alloc] init];
        layout.streamId = self.videoMixID;
        layout.x = 0.5;
        layout.y = 0.5;
        layout.zOrder = 10;
        layout.width = 0.3;
        layout.height = 0.3;
        layout.renderMode = VeLivePusherRenderModeHidden;
        dec.mixVideoStreams = @[layout];
        //  Update video stream configuration
        [self.livePusher.getMixerManager updateStreamMixDescription:dec];
        
        VELVideoFileConfig *config = [[VELVideoFileConfig alloc] init];
        config.fileType = VELVideoFileType_YUV;
        config.name = @"video_320x180_25fps_yuv420.yuv";
        config.path = [NSBundle.mainBundle pathForResource:@"video_320x180_25fps_yuv420.yuv" ofType:nil];
        config.fps = 25;
        config.width = 320;
        config.height = 180;
        self.videoFileReader = [VeLiveFileReader readerWithConfig:config];
        self.videoFileReader.repeat = YES;
        [self.videoFileReader startWithDataCallBack:^(NSData * _Nullable data, CMTime pts) {
            VeLiveVideoFrame *videoFrame = [[VeLiveVideoFrame alloc] init];
            videoFrame.pts = pts;
            videoFrame.width = config.width;
            videoFrame.height = config.height;
            videoFrame.bufferType = VeLiveVideoBufferTypeNSData;
            videoFrame.data = data;
            videoFrame.pixelFormat = VeLivePixelFormatI420;
            //  Mix in video streams
            [self.livePusher.getMixerManager sendCustomVideoFrame:videoFrame streamId:self.videoMixID];
        } completion:^(NSError * _Nullable error, BOOL isEnd) {
            vel_sync_main_queue(^{
                [self.videoFileReader stop];
                [self.livePusher.getMixerManager removeVideoStream:self.videoMixID];
                sender.selected = NO;
            });
        }];
        sender.selected = YES;
    } else {
        [self.videoFileReader stop];
        [self.livePusher.getMixerManager removeVideoStream:self.videoMixID];
        sender.selected = NO;
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
    self.title = NSLocalizedString(@"Push_Mix_Stream", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlLabel.text = NSLocalizedString(@"Push_Url_Tip", nil);
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Start_Push", nil) forState:(UIControlStateNormal)];
    [self.pushControlBtn setTitle:NSLocalizedString(@"Push_Stop_Push", nil) forState:(UIControlStateSelected)];
    [self.mixAudioControlBtn setTitle:NSLocalizedString(@"Push_Mix_Stream_Audio", nil) forState:(UIControlStateNormal)];
    [self.mixAudioControlBtn setTitle:NSLocalizedString(@"Push_Mix_Stream_Audio", nil) forState:(UIControlStateSelected)];
    [self.mixVideoControlBtn setTitle:NSLocalizedString(@"Push_Mix_Stream_Video", nil) forState:(UIControlStateNormal)];
    [self.mixVideoControlBtn setTitle:NSLocalizedString(@"Push_Mix_Stream_Video", nil) forState:(UIControlStateSelected)];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
