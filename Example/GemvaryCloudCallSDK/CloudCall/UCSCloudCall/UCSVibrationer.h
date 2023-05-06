//
//  UCSVibrationer.h
//  UCS_IM_Demo
//
//  Created by Barry on 2017/4/20.
//  Copyright © 2017年 Barry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//持续振动效果
@interface UCSVibrationer : NSObject
+ (instancetype )instance;

- (void)addVibrate ;
- (void)removeVibrate ;
@end
