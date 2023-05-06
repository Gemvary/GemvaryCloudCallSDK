//
//  UCSVideoCallController.m
//  UCS_Demo_OC
//
//  Created by gemvary on 2017/12/25.
//  Copyright © 2017年 gemvary. All rights reserved.
//

#import "UCSVideoCallController.h"
#import <AVFoundation/AVFoundation.h>
//#import "DBOperation.h"
#import "MarqueeView.h"

#import <GemvaryCloudCallSDK/UCSFuncEngine.h>
#import <GemvaryCloudCallSDK/UCSTCPSDK.h>
#import "UCSSoundEffect.h"
#import "UCSVibrationer.h"

#import "UCSVoipCallController.h"

#import <GemvaryToolSDK/GemvaryToolSDK-Swift.h>
#import "GemvaryCloudCallSDK_Example-Swift.h"
#import <GemvaryCommonSDK/GemvaryCommonSDK-Swift.h>
#import <GemvaryNetworkSDK/GemvaryNetworkSDK-Swift.h>
#import <RealReachability/RealReachability.h>

#import <UserNotifications/UserNotifications.h>

static NSInteger const UCS_dismissCallVC_delayTime = 1;

@interface UCSVideoCallController ()<UCSEngineUIDelegate>
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *handFreeButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIButton *openDoorButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callStatusTop;
@property (weak, nonatomic) IBOutlet UIStackView *buttonsBgView;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet MarqueeView *marqueeView;
@property (weak, nonatomic) IBOutlet UILabel *callStatusLabel;//通话状态
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *callStatusLabelLayoutConstraintTop;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;


@property (weak, nonatomic)  UIView *videoRemoteView;
@property (weak, nonatomic)  UIView *videoLocationView;
@property (nonatomic) BOOL isRinging;//播放铃声
@property (nonatomic) BOOL isVibrating;//播放振动
@property (nonatomic) BOOL isCalling;//通话中

@end

@implementation UCSVideoCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"%@ __alloc__", NSStringFromClass([self class]));
    
    //距离感应, 息屏
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    // 设置UI代理
    [UCSFuncEngine shared].UIDelegate = self;
    
    [self makeVideoCallView];
    
    [[UCSFuncEngine shared] setVideoPresetWith:UCS_VIE_PROFILE_PRESET_640x480];
    [[UCSFuncEngine shared] setVideoIsUseHwEnc:NO];
    [[UCSFuncEngine shared] initCameraConfig:self.videoLocationView withRemoteVideoView:self.videoRemoteView withRender:RENDER_BLACKBORDER];
    
    [[UCSFuncEngine shared] switchVideoMode:CAMERA_NORMAL];
    
    [self addNoti];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UCSFuncEngine shared] switchCameraDevice:CAMERA_FRONT];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        // 播放铃声 声音
        [self playSoundEffect];
    }
    
    // 添加振动
    [self addVibrate];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    DebugLog(@"viewWillDisappear");
    // 为避免绿屏现象出现 将view颜色设置为黑色
    self.view.backgroundColor = UIColor.blackColor;
    
    // 移除震动
    [self removeVibrate];
    // 移除铃声
    [self removeSoundEffect];
    
//    [self.videoLocationView removeFromSuperview];
//    self.videoLocationView = nil;
    
//    [self.videoRemoteView removeFromSuperview];
//    self.videoRemoteView = nil;
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 挂断通话
    [UCSFuncEngine.shared reject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    DebugLog(@"%@ __dealloc__", NSStringFromClass([self class]));

    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //距离感应, 息屏
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    UCSFuncEngine* funcEngine = [UCSFuncEngine shared];
    // 旋转显示图像角度
    [funcEngine setRotationVideo:0 andRecivied:0];
    funcEngine.callType = UCSCallTypeNone;
    funcEngine.calledNumberList = nil;
    funcEngine.callid = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 界面规划
- (void)makeVideoCallView{
    //远程窗口
    self.videoRemoteView = [[UCSFuncEngine shared] allocCameraViewWithFrame:self.view.bounds];
    self.videoRemoteView.backgroundColor = [UIColor clearColor]; 
    [self.view addSubview:self.videoRemoteView];
    
    //本地窗口
    CGFloat videoLocationViewWidth = 90.0;
    CGFloat videoLocationViewHeight = 120;
    CGRect videoLocationViewFrame = CGRectMake([[UIScreen mainScreen] bounds].size.width - videoLocationViewWidth, [[UIScreen mainScreen] bounds].size.height - 110 - videoLocationViewHeight, videoLocationViewWidth, videoLocationViewHeight);
    self.videoLocationView = [[UCSFuncEngine shared] allocCameraViewWithFrame:videoLocationViewFrame];
    self.videoLocationView.backgroundColor = [UIColor clearColor];
    [self.videoLocationView setHidden:YES];
    [self.view addSubview:self.videoLocationView];
    
    [self.view bringSubviewToFront:self.buttonsBgView];
    // 更新UI
    [self updateUI];
}

- (void)startMarqueeWith:(NSString*)addressString{
    self.marqueeView.fontOfMarqueeLabel = 17.0;
    self.marqueeView.textArr = @[addressString];
    self.marqueeView.textColor = [UIColor whiteColor];
}

#pragma mark - event

- (IBAction)onMuteButton:(UIButton *)sender {
    DebugLog(@"onMuteButton");

    if ([UCSFuncEngine shared].isMicMute == YES) {
        [[UCSFuncEngine shared] setMicMute:NO];
        [self.muteButton setSelected:NO];
        DebugLog(@"非静音");
    }else{
        [[UCSFuncEngine shared] setMicMute:YES];
        [self.muteButton setSelected:YES];
        DebugLog(@"静音");
    }
}

- (IBAction)onHandFreeButton:(UIButton *)sender {
    DebugLog(@"onHandFreeButton");

    if ([UCSFuncEngine shared].isSpeakerphoneOn == YES) {
        [[UCSFuncEngine shared] setSpeakerphone:NO];
        [self.handFreeButton setSelected:NO];
        DebugLog(@"关闭免提");
    }else{
        [[UCSFuncEngine shared] setSpeakerphone:YES];
        [self.handFreeButton setSelected:YES];
        DebugLog(@"打开免提");
    }
}

#pragma mark  接通电话
- (IBAction)onAnswerButton:(UIButton *)sender {
    DebugLog(@"onAnswerButton");

    [self removeVibrate];
    [self removeSoundEffect];
    
    NSString* callid = [UCSFuncEngine shared].callid;
    if (callid) {
        DebugLog(@"接听: %@",callid);
        [[UCSFuncEngine shared] answer:callid];
    } else {
        // 挂断 无法接听
        [[UCSFuncEngine shared] reject:nil];
    }
}

#pragma mark  挂断电话
- (IBAction)onHangupButton:(UIButton *)sender {
    DebugLog(@"挂断电话 onHangupButton");
    
    [self disableAllButton];
    
    [self removeVibrate];
    [self removeSoundEffect];
    
    UCSFuncEngine* funcEngine = [UCSFuncEngine shared];
    [funcEngine hangUp:nil];
    
    [self hangupCall];
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:5.0];
    
//    [self releaseCallViewController];
}

// 点击开锁
- (IBAction)onOpenDoorButton:(UIButton *)sender {
    if (self.isCalling == YES) {
        DebugLog(@"点击开锁");
        [[UCSFuncEngine shared] sendDTMF:'#'];
    }else{
        DebugLog(@"点击开锁");
        // 33
         [self sendOpenOutdoorCommandWith:self.callinfo];
        
        UCSTCPTransParentRequest *tcp = [UCSTCPTransParentRequest initWithCmdString:@"unlock" receiveId:[self.callinfo objectForKey:@"callerNumber"]];
        [[UCSTcpClient sharedTcpClientManager] sendTransParentData:tcp success:^(UCSTCPTransParentRequest *request) {
            DebugLog(@"云对讲 视频 透传数据 发送成功 %@", request);
        } failure:^(UCSTCPTransParentRequest *request, UCSError *error) {
            DebugLog(@"云对讲 视频 透传数据 发送失败 %@", error);
        }];
    }
}

// 挂断电话 透传消息给云对讲
- (void)hangupCall {
    
    // self.callinfo objectForKey:@"callerNumber"
    DebugLog(@"云对讲的ID~.~: %@", self.callinfo);
    if (self.callinfo == nil) {
        return;
    }
    UCSTCPTransParentRequest *tcp = [UCSTCPTransParentRequest initWithCmdString:@"calleehangup" receiveId:[self.callinfo objectForKey:@"callerNumber"]];
    [[UCSTcpClient sharedTcpClientManager] sendTransParentData:tcp success:^(UCSTCPTransParentRequest *request) {
        DebugLog(@"云对讲 视频 透传数据 发送成功 %@", request);
    } failure:^(UCSTCPTransParentRequest *request, UCSError *error) {
        DebugLog(@"云对讲 视频 透传数据 发送失败 %@", error);
    }];
}

#pragma mark - private methods

- (void)addNoti{
    //耳机状态改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headPhoneChange:) name:UCSNotiHeadPhone object:nil];
    
    //监听前台 事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// 更新UI
- (void)updateUI{
    
    self.buttonsViewHeight.constant = 54.0;
	self.callStatusLabel.textColor = [UIColor whiteColor];
    
    switch ([UCSFuncEngine shared].callType) {
        case UCSCallTypeVoipCall:
        case UCSCallTypeVideoCall:
        case UCSCallTypePSTN:
        {
			self.callStatusLabel.text = NSLocalizedString(@"呼叫", nil);
            [self startMarqueeWith:self.toName];
            
            [self.muteButton setHidden:YES];
            [self.answerButton setHidden:YES];
            [self.openDoorButton setHidden:YES];
            [self.hangupButton setHidden:NO];
            [self.handFreeButton setHidden:YES];
            
            self.buttonsViewWidth.constant = 54.0;
        }
            break;
            
        case UCSCallTypeIncomingVoipCall:
        case UCSCallTypeIncomingVideoCall:
        {
            NSInteger devType = [[self.callinfo objectForKey:@"devType"] integerValue];
            DebugLog(@"视频来电的信息::: %@", self.callinfo);
            DebugLog(@"视频 设备类型：%ld", devType);
            
            NSString* alias = [self.callinfo objectForKey:@"note"];
            if (alias == nil) {
                alias = NSLocalizedString(@"未知", nil);
            }
            [self startMarqueeWith:alias];
			self.callStatusLabel.text = NSLocalizedString(@"来电", nil);
            
            switch (devType) {
                // 需要开锁
                case SipCallDeviceTypeWall:
                case SipCallDeviceTypeUnit:
                case SipCallDeviceTypeOutdoor:
                case SipCallDeviceTypeOutdoorSimu:
                {
                    [self.muteButton setHidden:YES];
                    [self.answerButton setHidden:NO];
                    [self.openDoorButton setHidden:NO];
                    [self.hangupButton setHidden:NO];
                    [self.handFreeButton setHidden:YES];
                    
                    self.buttonsBgView.spacing = (self.buttonsViewWidth.constant - 3*54.0)/2;
                    break;
                }
                default:
                {
                    [self.muteButton setHidden:YES];
                    [self.answerButton setHidden:NO];
                    [self.openDoorButton setHidden:YES];
                    [self.hangupButton setHidden:NO];
                    [self.handFreeButton setHidden:YES];
                    
                    self.buttonsBgView.spacing = (self.buttonsViewWidth.constant - 2*54.0);
                    break;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)updateUIWhenAnswer{
	if (self.openDoorButton.isHidden == true) {
		[self.muteButton setHidden:NO];
		[self.answerButton setHidden:YES];
		[self.openDoorButton setHidden:YES];
		[self.hangupButton setHidden:NO];
		[self.handFreeButton setHidden:NO];

		self.buttonsViewWidth.constant = 250;
		self.buttonsBgView.spacing = (self.buttonsViewWidth.constant - 3*54.0)/2;
	}else{
		[self.muteButton setHidden:NO];
		[self.answerButton setHidden:YES];
		[self.openDoorButton setHidden:NO];
		[self.hangupButton setHidden:NO];
		[self.handFreeButton setHidden:NO];

		self.buttonsViewWidth.constant = 250;
		self.buttonsBgView.spacing = (self.buttonsViewWidth.constant - 4*54.0)/3;
	}

	[UIView animateWithDuration:0.5 animations:^{
		self.callStatusTop.constant = 20.0;
		[self.view bringSubviewToFront:self.callStatusLabel];
		[self.view bringSubviewToFront:self.marqueeView];
	}];
}

- (void)disableAllButton{
    [self.muteButton setEnabled:NO];
    [self.handFreeButton setEnabled:NO];
    [self.answerButton setEnabled:NO];
    [self.hangupButton setEnabled:NO];
    [self.openDoorButton setEnabled:NO];
}

//检测是否有耳机
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

//耳机插拔通知
- (void)headPhoneChange:(NSNotification *)note{
    
    NSNumber * i = note.object;
    if (i.intValue == 1) {
        DebugLog(@"有耳机");
        //有耳机
        self.handFreeButton.selected = NO;
        self.handFreeButton.enabled = NO;
        [[UCSFuncEngine shared] setSpeakerphone:NO];
        
    }else if(i.intValue == 2){
        DebugLog(@"没耳机");
        [self.handFreeButton setEnabled:YES];
    }
}

//发送门口机开锁信息
- (void)sendOpenOutdoorCommandWith:(NSDictionary*)addressInfo{
    
    DebugLog(@"addressInfo: %@",addressInfo);
    NSString* devCode = [addressInfo objectForKey:@"devCode"];
    NSString* zoneid = [addressInfo objectForKey:@"zoneCode"];
    
    __weak typeof(self) weakSelf = self;
    // 开锁方式 2:来点开锁 1: 旧钥匙包开锁 15:钥匙包开锁(兼容后)
    [ScsPhoneWorkAPI phoneMsgForwardWithZoneCode:zoneid devcode:devCode msgType: 2 callBack:^(id _Nullable obj) {

        if (obj == nil) {
            DebugLog(@"网络请求错误");
            [ProgressHUD showText:NSLocalizedString(@"网络请求错误", nil)];
            return;
        }

        if ([obj isKindOfClass:[NSError class]]) {
            NSString* description = [obj localizedDescription];
            [ProgressHUD showText:NSLocalizedString(description, nil)];
            DebugLog(@"发送开门信息 报错: %@", description);
            return;
        }

        NSDictionary* dic = (NSDictionary*)obj;
        NSInteger code = [[dic objectForKey:@"code"] integerValue];

        switch (code) {
            case 200:
                DebugLog(@"发送开锁信息成功 %@ %@",devCode,zoneid);
                [ProgressHUD showText:NSLocalizedString(@"发送成功", nil)];
                break;

            case 552: {
//                [UserTokenLogin loginWithTokenWithCallBack:^{
//                    [self sendOpenOutdoorCommandWith:addressInfo];
//                }];
            }
                return;

            default:
                DebugLog(@"发送开锁信息失败");
                break;
        }

    }];
    // 延时100ms
    [NSThread sleepForTimeInterval:0.1];
    [ScsPhoneWorkAPI phoneMsgForwardWithZoneCode:zoneid devcode:devCode callBack:^(id _Nullable obj) {

        if (obj == nil) {
            DebugLog(@"网络请求错误");
            [ProgressHUD showText:NSLocalizedString(@"网络请求错误", nil)];
            return;
        }

        if ([obj isKindOfClass:[NSError class]]) {
            NSString* description = [obj localizedDescription];
            [ProgressHUD showText:NSLocalizedString(description, nil)];
            DebugLog(@"发送开门信息 报错: %@", description);
            return;
        }

        NSDictionary* dic = (NSDictionary*)obj;
        NSInteger code = [[dic objectForKey:@"code"] integerValue];

        switch (code) {
            case 200:
                DebugLog(@"发送开锁信息成功 %@ %@",devCode,zoneid);
                [ProgressHUD showText:NSLocalizedString(@"发送成功", nil)];
                break;

            case 552: {
//                [UserTokenLogin loginWithTokenWithCallBack:^ {
//                    [self sendOpenOutdoorCommandWith:addressInfo];
//                }];
            }
                return;

            default:
                DebugLog(@"发送开锁信息失败");
                break;
        }

    }];
}

//视频分级编码参数
- (void)setHierEncArrt{
    
    //------------------------视频分级编码参数-----------------------------//
    UCSHierEncAttr * hierEncAttr = [[UCSHierEncAttr alloc]init];
    
    hierEncAttr.low_complexity_w240 = 2;
    hierEncAttr.low_complexity_w360 = 1;
    hierEncAttr.low_complexity_w480 = 1;
    hierEncAttr.low_complexity_w720 = 0;
    hierEncAttr.low_bitrate_w240 =  200;
    hierEncAttr.low_bitrate_w360 =  -1;
    hierEncAttr.low_bitrate_w480 =  -1;
    hierEncAttr.low_bitrate_w720 =  -1;
    hierEncAttr.low_framerate_w240 = 12;
    hierEncAttr.low_framerate_w360 = 14;
    hierEncAttr.low_framerate_w480 = -1;
    hierEncAttr.low_framerate_w720 = 14;
    
    hierEncAttr.medium_complexity_w240 = 3;
    hierEncAttr.medium_complexity_w360 = 2;
    hierEncAttr.medium_complexity_w480 = 1;
    hierEncAttr.medium_complexity_w720 = 0;
    hierEncAttr.medium_bitrate_w240 = 200;
    hierEncAttr.medium_bitrate_w360 = 400;
    hierEncAttr.medium_bitrate_w480 = -1;
    hierEncAttr.medium_bitrate_w720  = -1;
    hierEncAttr.medium_framerate_w240 = 14;
    hierEncAttr.medium_framerate_w360 = 14;
    hierEncAttr.medium_framerate_w480 = 13;
    hierEncAttr.medium_framerate_w720 = 14;
    
    hierEncAttr.high_complexity_w240 = 3;
    hierEncAttr.high_complexity_w360 = 2;
    hierEncAttr.high_complexity_w480 = 2;
    hierEncAttr.high_complexity_w720 = 1;
    hierEncAttr.high_bitrate_w240 = 200;
    hierEncAttr.high_bitrate_w360 = 400;
    hierEncAttr.high_bitrate_w480 = -1;
    hierEncAttr.high_bitrate_w720 = -1;
    hierEncAttr.high_framerate_w240 = 14;
    hierEncAttr.high_framerate_w360 = 15;
    hierEncAttr.high_framerate_w480 = 15;
    hierEncAttr.high_framerate_w720 = 14;
    
    [[UCSFuncEngine shared] setHierEncAttr:hierEncAttr];
    
}

- (void)setVideoEnc{
    
    UCSVideoEncAttr *vEncAttr = [[UCSVideoEncAttr alloc] init] ;
    vEncAttr.uStartBitrate = 300;
    vEncAttr.uMaxBitrate = 900;
    vEncAttr.uMinBitrate = 150;
    
    [[UCSFuncEngine shared] setVideoAttr:vEncAttr];
    
    //设置视频来电时是否支持预览。
//    [[UCSFuncEngine shared] setCameraPreViewStatu:YES];
}

- (void)releaseCallViewController{
    
    DebugLog(@"releaseCallViewController from");
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        // 移除已传递并保留在通知中心的通知 iOS10
        [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // iOS8移除所有通知
        [UIApplication.sharedApplication cancelAllLocalNotifications];
    } else {
        //
        DebugLog(@"iOS8 以前的通知");
    }
	__weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UCS_dismissCallVC_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismiss];
    });
}

- (void)dismiss{
//    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if ([UCSTcpClient sharedTcpClientManager].login_isConnected == NO) {            
            // 判断网络状态
            if ([UCSTcpClient sharedTcpClientManager].getCurrentNetWorkStatus == UCSReachableViaUnknown ||
                [UCSTcpClient sharedTcpClientManager].getCurrentNetWorkStatus == UCSNotReachable ||
                [RealReachability.sharedInstance currentReachabilityStatus] <= 0) {
                // 没有网络
                [ProgressHUD showText:@"没有网络，请检查网络"];
            } else {
//                [UserTokenLogin repeatLoginWithTitle:NSLocalizedString(@"此账号已在别处登录，请重新登录~", nil)];
            }
        }
    }];
}

//播放铃声
- (void)playSoundEffect{
    if (self.isRinging == NO) {
        DebugLog(@"开始铃声");
        [[UCSSoundEffect instance] playSoundEffect];
        self.isRinging = YES;
    }
}

//移除铃声
- (void)removeSoundEffect{
    if (self.isRinging == YES) {
        DebugLog(@"移除铃声");
        [[UCSSoundEffect instance] removeSoundEffect];
        self.isRinging = NO;
    }
}

//开始振动
- (void)addVibrate{
    switch ([UCSFuncEngine shared].callType) {
        case UCSCallTypeIncomingVoipCall:
        case UCSCallTypeIncomingVideoCall:
        {
            if (self.isVibrating == NO) {
                DebugLog(@"开始振动");
                [[UCSVibrationer instance] addVibrate];
                self.isVibrating = YES;
            }
        }
            break;
            
        default:
            break;
    }
}

//移除振动
- (void)removeVibrate{
    
    switch ([UCSFuncEngine shared].callType) {
        case UCSCallTypeIncomingVoipCall:
        case UCSCallTypeIncomingVideoCall:
            
            if (self.isVibrating == YES) {
                DebugLog(@"移出振动");
                //振动
                [[UCSVibrationer instance] removeVibrate];
                self.isVibrating = NO;
            }
            break;
            
        default:
            break;
    }
}


- (void)willEnterForeground:(NSNotification *)notif {
    if (self.isCalling == NO) {
        [self playSoundEffect];
    }
}

#pragma mark - UCSEngineUIDelegate
/// 通话状态回调
- (void)responseVoipManagerStatus:(UCSCallStatus)event callID:(NSString *)callid data:(UCSReason *)data{
    
    //NSDictionary* roomInfo = roomInfoList.lastObject;(@"UCSCallStatus: %ld, callid: %@, reason: %ld, msg: %@", (long)event, callid, (long)data.reason, data.msg);
    
    NSLog(@"通话状态回调 UCSCallStatus: %ld, callid: %@, reason: %ld, msg: %@", (long)event, callid, (long)data.reason, data.msg);
    
    NSDictionary* roomInfo = [[NSDictionary alloc] init];
    
    self.marqueeView.hidden = NO;
    
    UCSFuncEngine* funcEngine = [UCSFuncEngine shared];
    
    switch (event)
    {
        case UCSCallStatus_Alerting:
        {
            DebugLog(@"呼叫振铃回调 %@", callid);
            
            funcEngine.callid = callid;
            [funcEngine setSpeakerphone:YES];
            
            self.callStatusLabel.text = NSLocalizedString(@"对方振铃", nil);
            //设置视频分级编码，需在通话接通前调用
            [self setHierEncArrt];
            
        }
            break;
            
        case UCSCallStatus_Answered:
        {
            DebugLog(@"接听回调 %@", callid);
            
            self.isCalling = YES;
            self.previewImageView.hidden = YES;

			[self updateUIWhenAnswer];
            [self removeVibrate];
            [self removeSoundEffect];
            
            self.callStatusLabel.text = NSLocalizedString(@"通话中...", nil);
            [self setVideoEnc];
            
//            [DBOperation insertAnswerCallrecords];
            
            [funcEngine setSpeakerphone:NO];
            if ([self isHeadsetPluggedIn]) {
                //有耳机
                self.handFreeButton.selected = NO;
                self.handFreeButton.enabled = NO;
            }else{
                //无耳机
                [funcEngine setSpeakerphone:NO];
            }
            
            // 原来的代码
//            if (funcEngine.callType == UCSCallTypeIncomingVideoCall && [[self.callinfo objectForKey:@"callerNumber"] hasPrefix:@"jhrt"]) {
//                DebugLog(@"准备旋转 让屏幕竖直");
//                [funcEngine setRotationVideo:0 andRecivied:270];
//            }
            if (funcEngine.callType == UCSCallTypeIncomingVideoCall && [self.callinfo objectForKey:@"unitno"] != nil) {
                // 旋转显示图像角度 // sipAddr // 原来字段是：callerNumber
                /*
                 funcEngine.callType == UCSCallTypeIncomingVideoCall && [[self.callinfo objectForKey:@"unitno"] hasPrefix:@"030303"]
                 */
                DebugLog(@"准备旋转 让屏幕竖直");
                [funcEngine setRotationVideo:0 andRecivied:270];
            }
        }
            break;
            
        case UCSCallStatus_Released: // 主机已经挂机
        {
            DebugLog(@"UCSCallStatus_Released 1");
            if (data.reason != CallEndedErrorCode_HungupCall || [UCSTcpClient sharedTcpClientManager].login_isConnected == NO) {
                DebugLog(@"UCSCallStatus_Released 2");
                [self disableAllButton];
                [self removeVibrate];
                [self removeSoundEffect];
            }
            
            switch (data.reason) {
                case CallEndedErrorCode_HungupCall:
                    self.callStatusLabel.text = NSLocalizedString(@"已挂机", nil);
                    break;
                case CallEndedErrorCode_HungupPeer:
                    self.callStatusLabel.text = NSLocalizedString(@"对方挂机", nil);
                    break;
                case CallEndedErrorCode_UnkownError:
					self.callStatusLabel.text = NSLocalizedString(@"已有关联账号接听电话", nil);
                    break;
                default:
                    break;
            }
            
            DebugLog(@"UCSCallStatus_Released release view from");
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self releaseCallViewController];
            DebugLog(@"UCSCallStatus_Released release view end");
        }
            break;
        case UCSCallStatus_Failed:
        {
            DebugLog(@"UCSCallStatus_Failed from");
            
            [self disableAllButton];
            [self removeVibrate];
            [self removeSoundEffect];

			self.callStatusLabel.text = NSLocalizedString(@"呼叫失败", nil);

            switch (data.reason) {
                case CallEndedErrorCode_HungupPeer://对方已挂机
                    self.callStatusLabel.text = NSLocalizedString(@"对方挂机", nil);
                    break;
                case CallFailedErrorCode_Reject://被叫拒绝接听
                    self.callStatusLabel.text = NSLocalizedString(@"对方拒接", nil);
                    break;
                case CallFailedErrorCode_Busy://对方忙(正在通话中)
                    self.callStatusLabel.text = NSLocalizedString(@"对方正在通话", nil);
                    break;
                case CallFailedErrorCode_NoAnswer://被叫无应答
                    self.callStatusLabel.text = NSLocalizedString(@"被叫无应答", nil);
                    [self releaseCallViewController];
                    [self callSipNumber];
                    return;
                case CallFailedErrorCode_NotFind://被叫不在线
                    self.callStatusLabel.text = NSLocalizedString(@"对方不在线", nil);
                    [self releaseCallViewController];
                    [self callSipNumber];
                    return;
                case CallEndedErrorCode_MsgTimeOut://信令超时
                    self.callStatusLabel.text = NSLocalizedString(@"信令超时", nil);
                    [self releaseCallViewController];
                    [self callSipNumber];
                    return;
                case CallFailedErrorCode_UnReachable://消息不可及(路由不可达)
                    self.callStatusLabel.text = NSLocalizedString(@"消息不可及", nil);
                    [self releaseCallViewController];
                    [self callSipNumber];
                    return;;
                case CallFailedErrorCode_TooShort://被叫号码异常
                    self.callStatusLabel.text = NSLocalizedString(@"被叫号码异常", nil);
                    break;
                case CallFailedErrorCode_UserIdNotExist://被叫不存在
                    self.callStatusLabel.text  = NSLocalizedString(@"被叫不存在", nil);
					break;
				case CallFailedErrorCode_BlackList://呼叫失败(线路频繁呼叫已被列入黑名单)
					self.callStatusLabel.text  = NSLocalizedString(@"线路频繁呼叫已被列入黑名单", nil);
                    break;
                default:
                    break;
            }
            
            [self releaseCallViewController];
        }
            break;
            
        default:
        {
            [self disableAllButton];
            [self removeVibrate];
            [self removeSoundEffect];
            [self releaseCallViewController];
        }
            break;
    }
    
}

/// 呼叫电话
- (void)callSipNumber {
    NSLog(@"呼叫电话");
    // 延时弹出提示框
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 弹出提示框
        if ([self.type isEqual:@"butler"]) {
            // 替换字符串
            NSString *telStr = [self.calledNumber stringByReplacingOccurrencesOfString:[self.calledNumber substringWithRange:NSMakeRange(3,4)]withString:@"****"];
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"呼叫%@", telStr] preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *openUrl = [NSURL URLWithString: [NSString stringWithFormat:@"tel:%@", self.calledNumber]];
                [UIApplication.sharedApplication openURL: openUrl];
            }]];
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVC animated:true completion:nil];
        };
    });
}



//DTMF回调
- (void)onDTMF:(NSString*)value{
    DebugLog(@"onDTMF : %@", value);
}


//视频通话前被叫显示主叫预览图片时回调
- (void)onReceivedPreviewImg:(UIImage *)image  callid:(NSString *)callid error:(NSError *)error{
    DebugLog(@"图片 callid: %@  error: %@", callid, error.localizedDescription);
    [[UCSTcpClient sharedTcpClientManager] setTransAckData:@"OK"];
    if (error == nil && !self.isCalling) {
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:1.0 animations:^{
            //weakSelf.callStatusLabelLayoutConstraintTop.constant = 0;
            //weakSelf.headerImageView.hidden = YES;
            weakSelf.previewImageView.image = image;
            // 视频呼叫时 隐藏预览图片
            weakSelf.previewImageView.hidden = YES;
            weakSelf.previewImageView.contentMode = UIViewContentModeScaleAspectFit;
        }];
    }
}

- (void)onReceivedPreviewImgUrl:(NSString *)imageurl callid:(NSString *)callid error:(NSError *)error{
    DebugLog(@"图片 imageurl: %@ callid: %@  error: %@", imageurl, callid, error.localizedDescription);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
