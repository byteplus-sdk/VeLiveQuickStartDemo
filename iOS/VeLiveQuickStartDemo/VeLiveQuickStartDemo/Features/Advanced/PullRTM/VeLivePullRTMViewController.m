/**
 * Copyright (c) 2023 BytePlus Pte. Ltd. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  VeLivePullRTMViewController.m
//  VeLiveQuickStartDemo
//
//  Created by BytePlus Team on 2024/4/11.
//

#import "VeLivePullRTMViewController.h"
/*
rtm Live streaming
 This document shows how to integrate the rtm live streaming function
 1, initialize the pusher API: self.livePlayer = [[TVLManager alloc] initWithOwnPlayer: YES];
 2, configure the pusher API: [self.livePlayer setConfig: [[VeLivePlayerConfiguration alloc] init]];
 3, configure the rendering view API: [self.view insertSubview: self.livePlayer.playerView atIndex: 0];
 4, configure the broadcast address API: [self.livePlayer setUrPlayl: @"http://pull.example.com/pull.flv"];
 5, start playing API: [self.livePlayer play];
 */
#import "VeLivePullRTMViewController.h"
#import "VeLiveSDKHelper.h"
@interface VeLivePullRTMViewController () <VeLivePlayerObserver>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (nonatomic, strong) TVLManager *livePlayer;
@property (weak, nonatomic) IBOutlet UIButton *playControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *fillModeControlBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteControlBtn;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@end

@implementation VeLivePullRTMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCommonUIConfig];
    [self setupLivePlayer];
}

- (void)dealloc {
    //  Destroy the live stream player
    //  When processing business, try not to release it here. It is recommended to release it when exiting the live stream.
    [self.livePlayer destroy];
}

- (void)setupLivePlayer {
    //  Create a live stream player
    self.livePlayer = [[TVLManager alloc] initWithOwnPlayer:YES];
    
    //  Set player callback
    [self.livePlayer setObserver:self];
    
    //  Configure the player
    VeLivePlayerConfiguration *cfg = [[VeLivePlayerConfiguration alloc] init];
    
    //  Whether to enable periodic information callbacks
    cfg.enableStatisticsCallback = YES;
    
    //  Periodic information callback interval
    cfg.statisticsCallbackInterval = 1;
    
    //  Whether to enable internal DNS resolution
    cfg.enableLiveDNS = YES;
    
    //  Configure the pull stream player
    [self.livePlayer setConfig:cfg];
    
    //  Configure Player View
    self.livePlayer.playerView.frame = self.view.bounds;
    [self.view insertSubview:self.livePlayer.playerView atIndex:0];
    
    //  Set render fill mode
    [self.livePlayer setRenderFillMode:(VeLivePlayerFillModeAspectFill)];
}

- (IBAction)playControl:(UIButton *)sender {
    if (self.urlTextField.text.length <= 0) {
        self.infoLabel.text = NSLocalizedString(@"config_stream_name_tip", nil);
        return;
    }
    if (sender.isSelected) {
        //  Stop playing
        [self.livePlayer stop];
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
            //  RTM Pull Stream Reference
            // main rtm url
            VeLivePlayerStream *playStreamRTM = [[VeLivePlayerStream alloc]init];
            playStreamRTM.url = [model.result getUrlWithProtocol:@"udp"];
            playStreamRTM.format = VeLivePlayerFormatRTM;
            
            // backup flv url
            VeLivePlayerStream *playStreamFLV = [[VeLivePlayerStream alloc]init];
            playStreamFLV.url = [model.result getUrlWithProtocol:@"flv"];
            playStreamFLV.format = VeLivePlayerFormatFLV;
            
            // Create VeLivePlayerStreamData
            VeLivePlayerStreamData *streamData = [[VeLivePlayerStreamData alloc]init];
            streamData.mainStream = @[playStreamRTM, playStreamFLV];
            streamData.defaultFormat = VeLivePlayerFormatRTM;
            /// http -> VeLivePlayerProtocolTCP,  https -> VeLivePlayerProtocolTLS
            streamData.defaultProtocol = VeLivePlayerProtocolTLS;
            [self.livePlayer setPlayStreamData:streamData];
            // start play
            [self.livePlayer play];
            sender.selected = !sender.isSelected;
        }];
    }
}

- (IBAction)fillModeControl:(UIButton *)sender {
    [self showFillModeAlert:^(VeLivePlayerFillMode mode) {
        //  Set fill mode
        [self.livePlayer setRenderFillMode:mode];
    }];
}

- (IBAction)muteControl:(UIButton *)sender {
    //  Mute/Unmute
    [self.livePlayer setMute:!sender.isSelected];
    sender.selected = !sender.isSelected;
}

// MARK: - VeLivePlayerObserver
- (void)onStatistics:(TVLManager *)player statistics:(VeLivePlayerStatistics *)statistics {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoLabel.attributedText = [VeLiveSDKHelper getPlaybackInfoString:statistics];
    });
}

- (void)onError:(TVLManager *)player error:(VeLivePlayerError *)error {
    NSLog(@"VeLiveQuickStartDemo: Error %ld, %@", error.code, error.errorMsg);
}

- (void)showFillModeAlert:(void (^)(VeLivePlayerFillMode mode))block {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Pull_Stream_Fill_Mode_Alert_Title", nil)
                                                                   message:nil
                                                            preferredStyle:(UIAlertControllerStyleActionSheet)];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Pull_Stream_Fill_Mode_Alert_AspectFill", nil)
                                              style:(UIAlertActionStyleDefault)
                                            handler:^(UIAlertAction * _Nonnull action) {
        block(VeLivePlayerFillModeAspectFill);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Pull_Stream_Fill_Mode_Alert_AspectFit", nil)
                                              style:(UIAlertActionStyleDefault)
                                            handler:^(UIAlertAction * _Nonnull action) {
        block(VeLivePlayerFillModeAspectFit);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Pull_Stream_Fill_Mode_Alert_FullFill", nil)
                                              style:(UIAlertActionStyleDefault)
                                            handler:^(UIAlertAction * _Nonnull action) {
        block(VeLivePlayerFillModeFullFill);
    }]];
    [self showDetailViewController:alert sender:nil];
}

- (void)setupCommonUIConfig {
    self.title = NSLocalizedString(@"Pull_Stream", nil);
    self.navigationItem.backBarButtonItem.title = nil;
    self.navigationItem.backButtonTitle = nil;
    self.urlLabel.text = NSLocalizedString(@"Pull_Stream_Url_Tip", nil);
    [self.playControlBtn setTitle:NSLocalizedString(@"Pull_Stream_Start_Play", nil) forState:(UIControlStateNormal)];
    [self.playControlBtn setTitle:NSLocalizedString(@"Pull_Stream_Stop_Play", nil) forState:(UIControlStateSelected)];
    
    [self.muteControlBtn setTitle:NSLocalizedString(@"Pull_Mute", nil) forState:((UIControlStateNormal))];
    [self.muteControlBtn setTitle:NSLocalizedString(@"Pull_UnMute", nil) forState:((UIControlStateSelected))];
    
    [self.fillModeControlBtn setTitle:NSLocalizedString(@"Pull_Fill_Mode", nil) forState:((UIControlStateNormal))];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
