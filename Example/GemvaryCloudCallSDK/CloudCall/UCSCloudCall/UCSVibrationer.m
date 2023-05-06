//
//  UCSVibrationer.m
//  UCS_IM_Demo
//
//  Created by Barry on 2017/4/20.
//  Copyright © 2017年 Barry. All rights reserved.
//

#import "UCSVibrationer.h"

@implementation UCSVibrationer

static id _instace;
+(instancetype)instance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [[self alloc] init];
    });
    return _instace;
}

- (void)addVibrate {
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, vibrateCallback, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)removeVibrate {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(triggerShake)
                                               object:nil];
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
//    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
}

void vibrateCallback(SystemSoundID sound,void * clientData) {
    [_instace performSelector:@selector(triggerShake) withObject:nil afterDelay:0.6];
}

- (void)triggerShake{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); //震动
}


@end
