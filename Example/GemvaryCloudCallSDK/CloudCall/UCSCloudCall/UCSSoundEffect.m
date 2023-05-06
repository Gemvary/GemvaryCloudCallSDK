//
//  UCSSoundEffect.m
//  UCS_IM_Demo
//
//  Created by Barry on 2017/4/27.
//  Copyright © 2017年 Barry. All rights reserved.
//

#import "UCSSoundEffect.h"
#import <AudioToolbox/AudioServices.h>

@interface UCSSoundEffect ()
{
    SystemSoundID soundID;
    
}
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation UCSSoundEffect


static id _instace;
+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (void)removeSoundEffect {
    
    [self.timer invalidate];
    self.timer = nil;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    AudioServicesDisposeSystemSoundID(soundID);
}

- (void)playSoundEffect {
    //获取路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ring" ofType:@"caf"];
    
    //判断路径是否存在
    if (path) {
        //创建一个音频文件的播放系统声音服务器
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)([NSURL fileURLWithPath:path]), &soundID);
        //判断是否有错误
        if (error != kAudioServicesNoError) {
            DebugLog(@"Could not load %@, error code: %d", path, (int)error);
        }
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:31.6 target:self selector:@selector(loopPlaySoundEffect) userInfo:nil repeats:YES];
    [self.timer fire];
    
}

- (void)loopPlaySoundEffect{
    AudioServicesPlaySystemSound(soundID);
}


@end
