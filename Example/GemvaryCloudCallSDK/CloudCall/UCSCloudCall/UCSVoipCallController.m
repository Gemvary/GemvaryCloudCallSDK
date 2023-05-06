//
//  UCSVoipCallController.m
//  UCS_Demo_OC
//
//  Created by gemvary on 2017/12/25.
//  Copyright © 2017年 gemvary. All rights reserved.
//

#import "UCSVoipCallController.h"
#import <AVFoundation/AVFoundation.h>
//#import "DBOperation.h"
#import "MarqueeView.h"

#import <GemvaryCloudCallSDK/UCSFuncEngine.h>
#import <GemvaryCloudCallSDK/UCSTCPSDK.h>

//#import "SwiftHeader.h"
#import <GemvaryNetworkSDK/GemvaryNetworkSDK-Swift.h>
#import "GemvaryCloudCallSDK_Example-Swift.h"
#import <GemvaryToolSDK/GemvaryToolSDK-Swift.h>
#import <GemvaryCommonSDK/GemvaryCommonSDK-Swift.h>

static NSInteger const kUCSCallViewButtonsCount = 5;
static NSInteger const UCS_dismissCallVC_delayTime = 1;

@interface UCSVoipCallController ()<UCSEngineUIDelegate>
@property (weak, nonatomic) IBOutlet UIButton *muteButton;
@property (weak, nonatomic) IBOutlet UIButton *handFreeButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIStackView *buttonsBgView;
@property (weak, nonatomic) IBOutlet UIButton *openDoorButton;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet MarqueeView *marqueeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeight;


@end

@implementation UCSVoipCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"%@ __alloc__", NSStringFromClass([self class]));
    
    // 为避免苹果8绿屏显现 将view颜色设置为黑色
    self.view.backgroundColor = UIColor.blackColor;
    
    [self becomeFirstResponder];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [UCSFuncEngine shared].UIDelegate = self;
    
    [self makeVideoCallView];
    
    [self.muteButton setEnabled:NO];
    [self.handFreeButton setEnabled:NO];
    
    [self addNoti];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)dealloc{
    DebugLog(@"%@ __dealloc__", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [UCSFuncEngine shared].UIDelegate = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - 界面规划
- (void)makeVideoCallView{
    
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

- (IBAction)onAnswerButton:(UIButton *)sender {
    DebugLog(@"onAnswerButton");
    
    [self.muteButton setEnabled:YES];
    [self.handFreeButton setEnabled:YES];
    
    NSString* callid = [UCSFuncEngine shared].callid;
    if (callid) {
        DebugLog(@"接听: %@",callid);
        [[UCSFuncEngine shared] answer:callid];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.answerButton setHidden:YES];
        self.buttonsViewWidth.constant = 54.0*(kUCSCallViewButtonsCount-1) + 8.0*(kUCSCallViewButtonsCount-2);
        self.buttonsBgView.spacing = 8.0;
    }];
}

#pragma mark  挂断通话
- (IBAction)onHangupButton:(UIButton *)sender {
    DebugLog(@"onHangupButton");
    UCSFuncEngine* funcEngine = [UCSFuncEngine shared];
    NSString* callid = funcEngine.callid;
    if (callid) {
        DebugLog(@"挂机: %@",callid);
        [funcEngine reject:callid];
    }else{
        DebugLog(@"挂机: hangUp");
        [funcEngine hangUp:@""];
    }
    
    // 挂断电话 透传消息给云对讲
    [self hangupCall];
    
    [self disableAllButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UCS_dismissCallVC_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            funcEngine.callType = UCSCallTypeNone;
            funcEngine.calledNumberList = nil;
            funcEngine.callid = nil;
            funcEngine.callViewController = nil;
            DebugLog(@"清除 funcEngine 成功");
        }];
    });
}

// 挂断电话 透传消息给云对讲
- (void)hangupCall {
    
    DebugLog(@"云对讲的ID~.~: %@", self.callinfo);
    if (self.callinfo == nil) {
        return;
    }
    UCSTCPTransParentRequest *tcp = [UCSTCPTransParentRequest initWithCmdString:@"calleehangup" receiveId:[self.callinfo objectForKey:@"callerNumber"]];
    [[UCSTcpClient sharedTcpClientManager] sendTransParentData:tcp success:^(UCSTCPTransParentRequest *request) {
        DebugLog(@"云对讲 语音 透传数据 发送成功 %@", request);
    } failure:^(UCSTCPTransParentRequest *request, UCSError *error) {
        DebugLog(@"云对讲 语音 透传数据 发送失败 %@", error);
    }];
}


- (IBAction)onOpenDoorButton:(UIButton *)sender {
    DebugLog(@"点击开锁");
     [self sendOpenOutdoorCommandWith:self.callinfo];
    
    UCSTCPTransParentRequest *tcp = [UCSTCPTransParentRequest initWithCmdString:@"unlock" receiveId:[self.callinfo objectForKey:@"callerNumber"]];
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
    
    /**
     踢线通知
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KickOffNoti) name:TCPKickOffNotification object:nil];
}

- (void)updateUI{
    
    self.buttonsViewHeight.constant = 54.0;
    self.buttonsBgView.spacing = 8.0;
    
    switch ([UCSFuncEngine shared].callType) {
        case UCSCallTypeVoipCall:
        case UCSCallTypeVideoCall:
        case UCSCallTypePSTN:
        {
            NSString* toName = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"呼叫", nil), self.toName];
            [self startMarqueeWith:toName];
            [self.answerButton setHidden:YES];
            [self.openDoorButton setHidden:YES];
            self.buttonsViewWidth.constant = 54.0*(kUCSCallViewButtonsCount - 2) + 8.0*(kUCSCallViewButtonsCount - 3);
        }
            break;
            
        default:
        {
            
            NSInteger devType = [[self.callinfo objectForKey:@"devType"] integerValue];
            
            NSString* alias = [self.callinfo objectForKey:@"note"];
            if (alias == nil) {
                alias = NSLocalizedString(@"未知", nil);
            }
            [self startMarqueeWith:alias];
            
            switch (devType) {
                case SipCallDeviceTypeWall:
                case SipCallDeviceTypeUnit:
                case SipCallDeviceTypeOutdoor:
                case SipCallDeviceTypeOutdoorSimu:
                case SipCallDeviceTypeOnlyfixed:
                case SipCallDeviceTypeRouterfixed:
                {
                    [self.openDoorButton setHidden:NO];
                    self.buttonsViewWidth.constant = 54.0*kUCSCallViewButtonsCount + 8.0*(kUCSCallViewButtonsCount -1);
                }
                    break;
                default:
                {
                    [self.openDoorButton setHidden:YES];
                    self.buttonsViewWidth.constant = 54.0*(kUCSCallViewButtonsCount - 1) + 8.0*(kUCSCallViewButtonsCount - 2);
                }
                    break;
            }
        }
            break;
    }
}

- (void)disableAllButton{
    [self.muteButton setEnabled:NO];
    [self.handFreeButton setEnabled:NO];
    [self.answerButton setEnabled:NO];
    [self.hangupButton setEnabled:NO];
    [self.openDoorButton setEnabled:NO];
}

/**
 被踢线
 */
-(void)KickOffNoti
{
    [self onHangupButton:nil];
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


//dic 转 json
- (NSString*)translationJson:(NSDictionary*)dic{
    NSData* data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString* jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return jsonStr;
}

//json 转 dic
- (NSDictionary*)translationDic:(NSString*)str{
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return dic;
}

- (NSString*)getDisplayNameString{
    //设置消息头
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    //NSArray* roomInfoList = [ud objectForKey:room_Info_List];
    //NSDictionary* roomInfo = roomInfoList.lastObject;
    NSDictionary* roomInfo = [[NSDictionary alloc] init];
    NSString* roomno = [roomInfo objectForKey:@"roomno"];
    NSString* unitName = [roomInfo objectForKey:@"unitName"];
    NSString* unitno = [roomInfo objectForKey:@"unitno"];
    
    NSString* alias = [NSString stringWithFormat:@"%@ %@",unitName, unitno];
    
    NSDictionary* dic = @{@"alias":alias,
                          @"devType":@(SipCallDeviceTypeMobile),
                          @"devCode":@"",
                          @"roomno":roomno,
                          @"unitno":unitno,
                          @"extno":@""};
    
    return [self translationJson:dic];
}

//解析消息头
- (NSDictionary*)parsingRemoteDisplay:(NSString*)display{
    return [self translationDic:display];
}

//发送门口机开锁信息
- (void)sendOpenOutdoorCommandWith:(NSDictionary*)addressInfo{
    
    DebugLog(@"addressInfo: %@",addressInfo);
    
    NSString* devCode = [addressInfo objectForKey:@"devCode"];
    NSString* zoneid = [addressInfo objectForKey:@"zoneCode"];
    
    __weak typeof(self) weakSelf = self;
    [ScsPhoneWorkAPI phoneMsgForwardWithZoneCode:zoneid devcode:devCode msgType:2 callBack:^(id _Nullable obj) {

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

#pragma mark - UCSEngineUIDelegate
/// 通话状态回调
- (void)responseVoipManagerStatus:(UCSCallStatus)event callID:(NSString *)callid data:(UCSReason *)data{
    self.marqueeView.hidden = NO;
    
    UCSFuncEngine* funcEngine = [UCSFuncEngine shared];
    
    switch (event)
    {
        case UCSCallStatus_Alerting:
        {
            
        }
            break;
            
        case UCSCallStatus_Answered:
        {
//            [DBOperation insertAnswerCallrecords];
            
            [self.muteButton setEnabled:YES];
            [self.handFreeButton setEnabled:YES];
            
            [funcEngine setSpeakerphone:NO];
            if ([self isHeadsetPluggedIn]) {
                //有耳机
                self.handFreeButton.selected = NO;
                self.handFreeButton.enabled = NO;
            }else{
                //无耳机
                [funcEngine setSpeakerphone:NO];
            }
        }
            break;
            
        case UCSCallStatus_Released:
        {
            [self disableAllButton];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UCS_dismissCallVC_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:^{
                    funcEngine.callType = UCSCallTypeNone;
                    funcEngine.calledNumberList = nil;
                    funcEngine.callid = nil;
                    funcEngine.callViewController = nil;
                    DebugLog(@"清除 funcEngine 成功");
                }];
            });
        }
            break;
        case UCSCallStatus_Failed: {
            switch (data.reason) {
                case CallEndedErrorCode_HungupPeer://对方已挂机
                    [ProgressHUD showText:NSLocalizedString(@"对方挂机", nil)];
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    break;
                case CallFailedErrorCode_Reject://被叫拒绝接听
                    [ProgressHUD showText:NSLocalizedString(@"对方拒接", nil)];
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    break;
                case CallFailedErrorCode_Busy://对方忙(正在通话中)
                    [ProgressHUD showText:NSLocalizedString(@"对方正在通话", nil)];
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    break;
                case CallFailedErrorCode_NoAnswer://被叫无应答
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    [self callSipNumber];
                    break;
                case CallFailedErrorCode_NotFind://被叫不在线
                    [ProgressHUD showText:NSLocalizedString(@"对方不在线", nil)];
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    [self callSipNumber];
                    break;
                case CallEndedErrorCode_MsgTimeOut://信令超时
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    [self callSipNumber];
                    break;
                case CallFailedErrorCode_UnReachable://消息不可及(路由不可达)
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    [self callSipNumber];
                    break;
                    
                default:
                    [self hangupCallWithFunEnging:funcEngine callid:callid];
                    break;
            }
        }
            break;
        case UCSCallStatus_Transfered://呼叫转移
        {
            [self disableAllButton];
            
        }
            break;
        case UCSCallStatus_Pasused://呼叫保持
        {
            
        }
            break;
        default:
            break;
    }
}


- (void)hangupCallWithFunEnging:(UCSFuncEngine *)funcEngine callid:(NSString *)callid {
    [funcEngine hangUp:callid];
    
    [self disableAllButton];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(UCS_dismissCallVC_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            funcEngine.callType = UCSCallTypeNone;
            funcEngine.calledNumberList = nil;
            funcEngine.callid = nil;
            funcEngine.callViewController = nil;
            DebugLog(@"清除 funcEngine 成功");
        }];
    });
}

/// 呼叫电话
- (void)callSipNumber {
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

@end
