//
//  UCSSoundEffect.h
//  UCS_IM_Demo
//
//  Created by Barry on 2017/4/27.
//  Copyright © 2017年 Barry. All rights reserved.
//

#import <Foundation/Foundation.h>

//持续播放短音效
@interface UCSSoundEffect : NSObject


+ (instancetype )instance;

- (void)removeSoundEffect;
- (void)playSoundEffect;

@end
